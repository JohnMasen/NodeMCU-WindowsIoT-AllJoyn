MQTTDevice={
    mqttRoot="/MQTTDevice",
    baseAddress="",
    properties={},
    methods={},
    lwtPath="",
    ddPath="",--device discover path
    signinPath="",
    host="",
    isConnected=false,
    debug=true,
    name="NodeMCU",
    serial="12345",
    description=""
    }

function MQTTDevice:new(name,serial,loginName,loginPwd,o)
    o= o or {}
    setmetatable(o,self)
    self.__index=self
    
    clientId=name..serial
    o.baseAddress=o.mqttRoot.."/"..name.."/"..serial
    o.lwtPath=o.mqttRoot.."/Offline"
    o.ddPath=o.mqttRoot.."/Discover"
    o.signinPath=o.mqttRoot.."/SignIn"
    
    o.client=mqtt.Client(clientId, 120, loginName, loginPwd)
    o.client:on("connect",function()
        o:onConnected()
    end)
    o.client:on("offline",function()
        o:onOffline()
    end)
    o.client:on("message",function(conn, topic, data)
        o:onMessage(conn,topic,data)
    end)
    
    o.properties["meta"]={}
    o.properties["meta"].read=function()
        return self:getMeta()
    end
    o.properties["meta"].type="s"
    
    return o
end

function MQTTDevice:start(host,port,secure)
    self:log("setup last will")
    self.client:lwt(self.lwtPath,self.baseAddress,0,0)
    self:log("connecting to server")
    self.client:connect(host,port,secure)
end

function MQTTDevice:onConnected()
    self.isConnected=true
    self:log("connected")
    self.client:subscribe(self.baseAddress,0)
    self:log("listening on ",self.baseAddress)
    self.client:subscribe(self.ddPath,0)
    self:log("listening device discover on ",self.ddPath)
    self.client:publish(self.signinPath,self:getMeta(),0,0)
    self:log("sign in sent on "..self.signinPath)
end
    
function MQTTDevice:onOffline()
    self.isConnected=false
    self:log("offline")
end

function MQTTDevice:onMessage(conn,topic,data)
    self:log("message arrived",topic,data)
    if topic == self.ddPath then
        self.client:publish(data,self:getMeta(),0,0)
        return
    end
    if topic==self.baseAddress then
        dataObj=cjson.decode(data)
        if dataObj==nil then return end
        local callback=dataObj["callback"] 
        local cmd=dataObj["cmd"] 
        local name=dataObj["name"] 
        local para=dataObj["para"] 
        if (callback) and (name) and (cmd) then
            self:processCommand(cmd,name,para,callback)
        else
            self:log("invalid json command")
        end
        return
    end
end

function MQTTDevice:processCommand(cmd,name,para,callback)
    if string.lower(cmd)=="read" then
        if not self.properties[name] then 
            self:log("trying to read on none existing property ["..name.."]")
            return 
        end
        if not self.properties[name].read then 
            self:log("property ["..name.."] does not support read")
            return 
        end
        local value=self.properties[name].read()
        if value then
            self.client:publish(callback,value,0,0)
            self:log("value sent",value,callback)
        end
    end
    if string.lower(cmd)=="write" then
        if not self.properties[name] then 
            self:log("trying to write on none existing property ["..name.."]")
            return 
        end
        if not self.properties[name].write then 
            self:log("property ["..name.."] does not support write")
            return 
        end
        if not para then
            self:log("write operation without a value")
            return
        end
        local value=self.properties[name].write(para)
    end    
    if string.lower(cmd)=="call" then
        if not self.methods[name] then 
            self:log("trying to call on none existing property ["..name.."]")
            return 
        end
        local value=self.methods[name].invoke(para)
        value=value or "SUCCESS"
        self.client:publish(callback,value,0,0)
    end
end

function MQTTDevice:getMeta()
    local result={}
    result["name"]=self.name
    result["serial"]=self.serial
    result["description"]=self.description
    result["address"]=self.baseAddress
    result["properties"]={}
    result["methods"]={}
    local i=1
    for k,v in pairs(self.properties) do
        result["properties"][i]={ name=k,
                    type=v.type,
                    direction=((v.read and "R") or "") .. ((v.write and "W") or "")
                   }
        i=i+1
    end
    i=1
    for k,v in pairs(self.methods) do
        result["methods"][i]={ name=k,
                    para=v.para  or {}
                   }
        i=i+1
    end
    return cjson.encode(result)
end

function MQTTDevice:log(...)
    if(self.debug==true) then
        print(unpack(arg))
    end
end
