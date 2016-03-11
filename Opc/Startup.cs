using System;
using System.Threading.Tasks;
using Microsoft.Owin;
using Owin;
using System.Web.Http;
using Microsoft.Owin.Cors;

[assembly: OwinStartup(typeof(Opc.Startup))]

namespace Opc
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
			// Setup the CORS middleware to run before SignalR.
			// By default this will allow all origins. You can 
			// configure the set of origins and/or http verbs by
			// providing a cors options with a different policy.
			app.UseCors(CorsOptions.AllowAll);

			HttpConfiguration httpConfiguration = new HttpConfiguration();
			WebApiConfig.Register(httpConfiguration);
			app.UseWebApi(httpConfiguration);
			
			app.MapSignalR();
            // For more information on how to configure your application, visit http://go.microsoft.com/fwlink/?LinkID=316888
        }
    }
	public class WebApiConfig
	{
		public static void Register(HttpConfiguration config)
		{
			config.Routes.MapHttpRoute(
				name: "api",
				routeTemplate: "api/{controller}"
				);
		}
	}
}
