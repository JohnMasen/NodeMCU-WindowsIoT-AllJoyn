cmdParser={}
cmdParser.processors={}

function cmdParser:new(o)
    o=o or {}
    o.processors={}
    o.processors["*"]=function(data) --default processor
        print("data="..data) 
    end
    setmetatable(o,self)
    self.__index=self
    return o
end
function Split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end      

function cmdParser:on(key,processor)
    self.processors[string.lower(key)]=processor
end

function cmdParser:parse(data)
    local tmp=Split(data," ")
    local cmd=""
    local para={}
    local count=1
    for i,v in ipairs(tmp) do
        if i==1 then
            cmd=v
        else
            if v~="" then
                para[count]=v
                count=count+1
            end
        end
        
    end
    local proc=self.processors[string.lower(cmd)] 
    if proc==nil then --no processor defined, goto default processor
        if self.processors["*"] ~= nil then --default processor found
            self.processors["*"](data) --process raw data
        end
    else    
        proc(para)
    end
end

