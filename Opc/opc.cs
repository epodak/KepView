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


		static UANodeElement GetNode(string server, EasyUAClient client, IEnumerable<string> path, UANodeElement parent)
		{
			if (!path.Any())
				return parent;
			UANodeElementCollection nodes = new UANodeElementCollection();
			if (parent==null)
			{
				nodes = client.BrowseObjects(server);
			}
			else
			{
				nodes = client.BrowseVariables(server, parent);
			}
			var node = nodes.SingleOrDefault(n => n.BrowseName.Name == path.First());
			if(node!=null)
				return GetNode(server, client, path.Skip(1), node);
			return null;
		}

		// GET api/<controller>
		// GET api/<controller>/5
		public IEnumerable<object> Get([FromUri] string[] path, string query = null)
		{
			
			var server = ConfigurationManager.AppSettings["opc-server"];
			using (var client = new EasyUAClient())
			{
				UANodeElement node= null;
				UANodeElementCollection nodes = new UANodeElementCollection();
				path = path.Where(p=>p!= null).ToArray();//.FirstOrDefault()?.Split('/');
				if (!path.Any())
					nodes = client.BrowseObjects(server);
				else
				{
					node = GetNode(server, client, path, null);
					if(node==null) return null;
						nodes = client.BrowseVariables(server, GetNode(server, client, path, null));
				}
				if(node!=null)
				{
					
					var ok2 = client.Read(new UANodeArguments(server, node.ToUANodeDescriptor()));
					var ok = client.Read(new UANodeArguments(server, node.ToUANodeDescriptor()), UAAttributeId.EventNotifier);
					var dvs = client.BrowseDataVariables(server, node);
					var dns = client.BrowseDataNodes(server, node);
					var ms = client.BrowseMethods(server, node);
					var obs = client.BrowseObjects(server, node);
					var prs = client.BrowseProperties(server, node);
					var vs = client.BrowseVariables(server, node);
					
				}
				
				var rets =
				nodes.Select(v =>
					new {
						BrowsePath = new
						{
							StartingNodeId = v.BrowsePath.StartingNodeId.StandardName,
							Elements = v.BrowsePath.Elements.Select(e => e.ToString())
						},
						v.DisplayName,
						BrowseName = v.BrowseName.ToString(),
						NodeId = new {
							v.NodeId.StandardName,
							v.NodeId.ExpandedText,
							v.NodeId.GuidIdentifierString,
							v.NodeId.StringIdentifier,
							v.NodeId.NumericIdentifier,
							v.NodeId.NamespaceIndex,
							v.NodeId.NamespaceUriString,
							v.NodeId.NodeIdType
						} ,
						ReferenceTypeId = v.ReferenceTypeId.StandardName,
						NodeClass = v.NodeClass.ToString(),
						StringIdentifier = v.NodeId?.StringIdentifier?.ToString()
					}).ToList();
				return rets;
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