using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace MQTTDSBCore
{
    [DataContract]
    public sealed class MQTTProperty
    {
        [DataMember(Name ="name")]
        public string Name { get; set; }
        [DataMember(Name ="type")]
        public string Type { get; set; }
        [DataMember(Name="direction")]
        public string Direction { get; set; }
        public bool CanRead
        {
            get
            {
                return Type.Contains("R");
            }
        }
        public bool CanWrite
        {
            get
            {
                return Type.Contains("W");
            }
        }
    }
}
