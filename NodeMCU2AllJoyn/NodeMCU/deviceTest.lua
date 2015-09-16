require "MQTTDevice"
device=MQTTDevice:new("test","12345","uid","pwd",{name="testDevice",serial="12345",description="this is a test device"})

t={}
t.read=function() return 10 end
t.type="s"

device.properties["temprature"]=t

print(device:getMeta())


device:start("192.168.1.100",1883)