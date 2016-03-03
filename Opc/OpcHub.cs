using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNet.SignalR;
using System.Reactive.Linq;
using System.Threading.Tasks;
using System.Collections.Concurrent;
using OpcLabs.EasyOpc.UA.Reactive;
using OpcLabs.EasyOpc.UA.Generic;
using OpcLabs.EasyOpc.UA.OperationModel;
using System.Threading;
using OpcLabs.EasyOpc.UA;
using static System.Diagnostics.Debug;

namespace Opc
{


    public class OpcHub : Hub
    {

        static Lazy<ConcurrentDictionary<string, GroupInfo>> GroupInfos = 
            new Lazy<ConcurrentDictionary<string, GroupInfo>>(() => 
                new ConcurrentDictionary<string, GroupInfo>());
        

        public override Task OnConnected()
        {
            System.Diagnostics.Debug.WriteLine("ok connected");
            return base.OnConnected();
        }
        public override Task OnDisconnected(bool stopCalled)
        {

            var removers = GroupInfos.Value.Values.ToList().Where(v => v.Connections.Contains(Context.ConnectionId)).Select(group =>
            {
                lock (group)
                {
                    group.Connections.Remove(Context.ConnectionId);
                    if (!group.Connections.Any())
                    {
                        var sub = group.SubscribeId;
                        group.SubscribeId = 0;
						group.Subscribed = false;
						group.Value = null;
                        return sub;
                    }
                    else
                        return 0;
                }


            }).Where(sub => sub != 0)
            .ToList();

            client.UnsubscribeMultipleMonitoredItems(removers);
            
            return base.OnDisconnected(stopCalled);
        }

        public static EasyUAClient client;
        public static void changes(object sender, EasyUAMonitoredItemChangedEventArgs e)
        {
            GroupInfo value;
            if(GroupInfos.Value.TryGetValue(e.Arguments.State.ToString(), out value)){
                lock(value)
                {
					WriteLine(e.Arguments.State.ToString());
                    if (e.Handle == value.SubscribeId)
                    {
                        value.Value = e;

                        GlobalHost.ConnectionManager.GetHubContext<OpcHub>()
                            .Clients.Group(e.Arguments.State.ToString()).broadcastMessage("tags", GetTagUpDate(e));
                    }
                    
                }

            }   
            else
                System.Diagnostics.Debug.WriteLine($"{e.Arguments.State.ToString()} NOT FOUND");
        }
		static object GetTagUpDate(EasyUAMonitoredItemChangedEventArgs e){
			return new
			{
				e.AttributeData?.Value,
				DisplayValue = e.AttributeData?.DisplayValue(),
				e.AttributeData?.ServerTimestamp,
				e.AttributeData?.SourceTimestamp,
				e.AttributeData?.HasGoodStatus,
				e.AttributeData?.HasBadStatus,
				e.AttributeData?.HasUncertainStatus,
				Exception = e.Exception?.Message,
				Succeeded = e.Succeeded,
				Node = e.Arguments.State.ToString()
			};
		 }

        public static void Setup()
        {
            client = new EasyUAClient();
            client.MonitoredItemChanged += changes;
        }
        
        public void Subscribe(IEnumerable<string> messages)
        {
            var addedGroups = messages.Select(node =>
            {
				WriteLine($"added:{node}");
                Groups.Add(Context.ConnectionId, node);
                var group = GroupInfos.Value.AddOrUpdate(node, new GroupInfo(node, Context.ConnectionId), (n, gi) =>
                {
					if(!gi.Connections.Contains(Context.ConnectionId))
                    gi.Connections.Add(Context.ConnectionId);
                    return gi;
                });
                lock (group)
                {
                    if (group.Value != null)
                        Clients.Client(Context.ConnectionId).broadcastMessage("tags", GetTagUpDate(group.Value));
                    if (!group.Subscribed)
                    {
                        group.Subscribed = true;
                        return group;
                    }
                    else
                        return null;
                }
            }).Where(g=>g!=null).ToList();

            
            var rr = client.SubscribeMultipleMonitoredItems(addedGroups.Select(g => ReadArgs(g.Name)).ToArray());

            rr.Select((i, id) => new { i, id }).ToList().ForEach(r => addedGroups.ElementAt(r.id).SubscribeId = r.i);
            
            
        }

        public void Remove(string name, IEnumerable<string> messages)
        {
            messages.ToList().ForEach(node => Groups.Remove(Context.ConnectionId, node));
               
        }

        static EasyUAMonitoredItemArguments ReadArgs(string node)
        {
            return new EasyUAMonitoredItemArguments(
                    node,
                    "opc.tcp://127.0.0.1:49320/",
                    $"ns=2;s={node}",
                    1000);
        }
        static UAMonitoredItemChangedObservable<object> ReadValues(string node)
        {
            return UAMonitoredItemChangedObservable.Create<object>(
                ReadArgs(node));
        }
    }

    public class GroupInfo
    {
        public GroupInfo(string name, string connection)
        {
            Name = name;
            Connections = new List<string> { connection };
            
        }
        public string Name { get; set; }
        public bool Subscribed { get; set; }
        public int SubscribeId { get; set; }
        public List<string> Connections { get; private set; }
        public EasyUAMonitoredItemChangedEventArgs Value { get; set; }
    }

}