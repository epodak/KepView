using System;
using System.Threading.Tasks;
using Microsoft.Owin;
using Owin;

[assembly: OwinStartup(typeof(Opc.Startup))]

namespace Opc
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            OpcHub.Setup();
            app.MapSignalR();
            // For more information on how to configure your application, visit http://go.microsoft.com/fwlink/?LinkID=316888
        }
    }
}
