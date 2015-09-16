using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using uPLibrary.Networking.M2Mqtt;
using uPLibrary.Networking.M2Mqtt.Messages;

namespace MQTTDSBCore
{
    public sealed class MQTTDeviceManager
    {
        public event EventHandler<MQTTDevice> DeviceSignIn;
        public event EventHandler<MQTTDevice> DeviceOffline;
        MqttClient client;
        private const string CLIENT_ID = "MQTT_AlljoynDSB";
        public string MQTTRoot { get; set; }
        public string DeviceDiscoverTopic { get; set; }
        public string DeviceSigninTopic { get; set; }
        
        public string DeviceDiscoverCallbackTopic { get; set; }
        public MQTTDeviceManager(string broker,int port)
        {
            MQTTRoot = "/MQTTDevice";
            DeviceDiscoverTopic = MQTTRoot + "/Discover";
            DeviceSigninTopic = MQTTRoot + "/SignIn";
            DeviceDiscoverCallbackTopic = MQTTRoot + "/AllJoyn/Devices";
            client = new MqttClient(broker,port,false,MqttSslProtocols.None);
            client.MqttMsgPublishReceived += Client_MqttMsgPublishReceived;
        }
        private void subscribe(string topic)
        {
            client.Subscribe(new string[] { topic }, new byte[] { MqttMsgBase.QOS_LEVEL_AT_MOST_ONCE });
        }

        private void Client_MqttMsgPublishReceived(object sender, MqttMsgPublishEventArgs e)
        {
            if (e.Topic== DeviceDiscoverCallbackTopic || e.Topic==DeviceSigninTopic)//device register(discover)
            {
                if (DeviceSignIn!=null)
                {
                    DeviceSignIn(this, MQTTDevice.Create(e.Message));
                }
                
            }
        }

        private string byteToString(byte[] buffer)
        {
            return System.Text.Encoding.UTF8.GetString(buffer);
        }

        public void Start(string uid,string pwd)
        {
            client.Connect(CLIENT_ID,uid,pwd);
            this.subscribe(DeviceDiscoverCallbackTopic);
            this.subscribe(DeviceSigninTopic);
            client.Publish(DeviceDiscoverTopic, Encoding.UTF8.GetBytes(DeviceDiscoverCallbackTopic));//public device discover message
        }
    }
}
