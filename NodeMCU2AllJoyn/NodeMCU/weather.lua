require "MQTTDevice"
local temperature=0
local humidity=0
local pressure=0


local DHT_Pin=1
local BMP_SDA=5
local BMP_SCK=6

local device=MQTTDevice:new("WeatherStation","0001","user1","pwd")
function init()
    device.debug=true
    
    device.properties["temprature"]={type="s"}
    device.properties["temprature"].read=function() 
        return temperature 
    end

    device.properties["humidity"]={type="s"}
    device.properties["humidity"].read=function() 
        return humidity 
    end

    device.properties["pressure"]={type="s"}
    device.properties["pressure"].read=function() 
        return pressure 
    end

    device:start("192.168.0.101",1883)
end
function readDHT()
    local status,temp,humi,temp_decimial,humi_decimial = dht.read(DHT_Pin)
    if( status == dht.OK ) then
        --temperature=temp
        humidity=humi
    end
end


function printValues()
    print("Temprature",temperature)
    print("Humidity",humidity)
    print("pressure",pressure)
end

function readBMP()
    temperature,pressure=dofile("bmp085_vla.lua").read(BMP_SDA, BMP_SCK)
end
init()
--tmr.delay(5000000) --wait 5 seconds
tmr.alarm(0,2000,1,function()
    readDHT()
    readBMP()
    printValues()
    print(node.heap())
end)
