using OpcLabs.EasyOpc.UA;
using OpcLabs.EasyOpc.UA.AddressSpace;
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
		// GET api/<controller>
		// GET api/<controller>/5
		public IEnumerable<object> Get(string resourcePath, string query = null)
		{
			
			var server = ConfigurationManager.AppSettings["opc-server"];
			using (var client = new EasyUAClient())
			{
				UANodeElementCollection nodes = new UANodeElementCollection();
				switch (query)
				{
					case "variables":
						nodes = client.BrowseVariables(server, $"ns=2;s={resourcePath?.Replace("/", ".")}");
						break;
					case "properties":
						nodes = client.BrowseProperties(server, $"ns=2;s={resourcePath?.Replace("/", ".")}");
						break;
					case "methods":
						nodes = client.BrowseMethods(server, $"ns=2;s={resourcePath?.Replace("/", ".")}");
						break;
					case "objects":
						nodes = client.BrowseObjects(server);//, $"ns=2;s={resourcePath?.Replace("/", ".")}");
						break;
					case "dataNodes":
						nodes = client.BrowseDataNodes(server, $"ns=2;s={resourcePath?.Replace("/", ".")}");
						break;
					case "dataVariables":
						nodes = client.BrowseDataVariables(server, $"ns=2;s={resourcePath?.Replace("/", ".")}");
						break;


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
						NodeId = v.NodeId.StandardName,
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