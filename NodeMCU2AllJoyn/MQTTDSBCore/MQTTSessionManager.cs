using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using uPLibrary.Networking.M2Mqtt;
using uPLibrary.Networking.M2Mqtt.Messages;
using Windows.Foundation;

namespace MQTTDSBCore
{
    public sealed class MQTTSessionManager
    {
        private Dictionary<string, TaskCompletionSource<byte[]>> sessions = new Dictionary<string, TaskCompletionSource<byte[]>>();
        MqttClient client;
        string baseAddress;
        public MQTTSessionManager(MqttClient client,string baseAddress)
        {
            this.client = client;
            this.baseAddress = baseAddress;
            client.MqttMsgPublishReceived += Client_MqttMsgPublishReceived;
        }

        private void Client_MqttMsgPublishReceived(object sender, MqttMsgPublishEventArgs e)
        {
            TaskCompletionSource<byte[]> tcs;
            if (sessions.TryGetValue(e.Topic, out tcs))
            {
                tcs.SetResult(e.Message);
            }
        }

        public async Task<T> Call<T>(string outputTopic, string callbackTopic,byte[] data)
        {
            subscribe(callbackTopic);
            TaskCompletionSource<T> tcs = new TaskCompletionSource<T>();
            client.Publish(outputTopic, data);
            return await tcs.Task;
        }

        private void subscribe(string topic)
        {
            client.Subscribe(new string[] { topic }, new byte[] { MqttMsgBase.QOS_LEVEL_AT_MOST_ONCE });
        }
        private void unsubscribe(string topic)
        {
            client.Unsubscribe(new string[] { topic });
        }
    }
}
