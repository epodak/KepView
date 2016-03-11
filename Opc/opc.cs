using OpcLabs.EasyOpc.UA;
using OpcLabs.EasyOpc.UA.AddressSpace;
using OpcLabs.EasyOpc.UA.OperationModel;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace Opc
{
	public class OpcController : ApiController
	{


		static IEnumerable<UANodeElement> GetNode(string server, EasyUAClient client, IEnumerable<string> path, IEnumerable<UANodeElement> currentNodes)
		{
			var _currentNodes = currentNodes ?? new List<UANodeElement>();
			if (!path.Any())
				return currentNodes;
			UANodeElementCollection nodes = new UANodeElementCollection();
			if (!_currentNodes.Any())
			{
				nodes = client.BrowseObjects(server);
				
			}
			else
			{
				nodes = client.BrowseVariables(server, currentNodes.Last());
			}
			var node = nodes.SingleOrDefault(n => n.BrowseName.Name == path.First());
			if(node!=null)
				return GetNode(server, client, path.Skip(1), _currentNodes.Concat(new List<UANodeElement> { node }));
			return new List<UANodeElement>();
		}


		static object NodeReturn(UANodeElement node)
		{
			if (node == null) return null;
			return new
			{
				BrowsePath = new
				{
					StartingNodeId = node.BrowsePath.StartingNodeId.StandardName,
					Elements = node.BrowsePath.Elements.Select(e => e.ToString())
				},
				node.DisplayName,
				BrowseName = node.BrowseName.ToString(),
				NodeId = new
				{
					node.NodeId.StandardName,
					node.NodeId.ExpandedText,
					node.NodeId.GuidIdentifierString,
					node.NodeId.StringIdentifier,
					node.NodeId.NumericIdentifier,
					node.NodeId.NamespaceIndex,
					node.NodeId.NamespaceUriString,
					node.NodeId.NodeIdType
				},
				ReferenceTypeId = node.ReferenceTypeId.StandardName,
				NodeClass = node.NodeClass.ToString()
			};
		}
		// GET api/<controller>
		// GET api/<controller>/5
		public object Get([FromUri] string[] path, string query = null)
		{
			
			var server = ConfigurationManager.AppSettings["opc-server"];
			using (var client = new EasyUAClient())
			{
				UANodeElementCollection nodes = new UANodeElementCollection();
				path = path.Where(p=>p!= null).ToArray();//.FirstOrDefault()?.Split('/');

				var nodePath = new List<UANodeElement>();
				if (!path.Any())
					nodes = client.BrowseObjects(server);
				else
				{
					nodePath = GetNode(server, client, path, null).ToList();
					if(!nodePath.Any()) return null;
					nodes = client.BrowseVariables(server, nodePath.Last());
				}
				

				return new { path = path.Select((p, i) => new {
					browseName = p,
					node = NodeReturn(nodePath.ElementAtOrDefault(i)) }),
					children = nodes.Select(NodeReturn) };
			}

				
		}

		// POST api/<controller>
		public void Post([FromBody]string value)
		{
		}

		// PUT api/<controller>/5
		public void Put(int id, [FromBody]string value)
		{
		}

		// DELETE api/<controller>/5
		public void Delete(int id)
		{
		}
	}
}