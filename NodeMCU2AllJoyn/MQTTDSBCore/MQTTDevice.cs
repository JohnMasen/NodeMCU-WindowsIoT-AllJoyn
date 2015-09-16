using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Threading.Tasks;

namespace MQTTDSBCore
{
    [DataContract]
    public sealed class MQTTDevice
    {
        [DataMember(Name = "address")]
        public string Address { get; set; }

        [DataMember(Name = "name")]
        public string Name { get; set; }

        [DataMember(Name = "Serial")]
        public string Serial { get; set; }

        [DataMember(Name = "description")]
        public string Description { get; set; }

        [DataMember(Name = "properties")]
        public MQTTProperty[] Properties { get; set; }

        public static MQTTDevice Create([System.Runtime.InteropServices.WindowsRuntime.ReadOnlyArray]byte[] json)
        {
            DataContractJsonSerializer s = new DataContractJsonSerializer(typeof(MQTTDevice));
            return s.ReadObject(new System.IO.MemoryStream(json)) as MQTTDevice;
        }
        public override int GetHashCode()
        {
            return Address.GetHashCode();
        }

    }


}
