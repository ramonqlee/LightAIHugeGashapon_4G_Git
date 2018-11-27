-- @module LogUtil
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2017.12.24
-- tested 2017.12.27
module(..., package.seeall)

require "Consts"
require "Config"
require "CloudConsts"
require "NodeIdConfig"

function ConcatTabValue( tab,split )
    if not tab or "table"~=type(tab) then
        return ""
    end

    local ret = ""
    for _,v in pairs(tab) do
        ret = ret..v..split
    end

    if #ret<#split then
        return ret
    end

    --remove last split
    ret = string.sub(ret,1,#ret-#split)

    return ret
end

function StringSplit(str,split)
    local lcSubStrTab = {}
    if not str or "string" ~= type(str) then
        return lcSubStrTab
    end
    
    while true do
        local lcPos = string.find(str,split)
        if not lcPos then
            lcSubStrTab[#lcSubStrTab+1] =  str    
            break
        end
        local lcSubStr  = string.sub(str,1,lcPos-1)
        lcSubStrTab[#lcSubStrTab+1] = lcSubStr
        str = string.sub(str,lcPos+1,#str)
    end
    return lcSubStrTab
end

function getTableLen( tab )
    local count = 0  

    if not tab then
        return 0
    end

    if "table"~=type(tab) then
        return count
    end

    for k,_ in pairs(tab) do  
        count = count + 1  
    end 

    return count
end



--缺省的nodeid，如果本地没有配置，则返回这个
-- local MQTT_USER_NAME = "1000029"
-- local MQTT_PASSWORD = "h1nixjgsko"
local MQTT_USER_NAME = "1000013"
local MQTT_PASSWORD = "13xindeceshiji"

-- 缓存
local nodeIdInConfig=""
local passwordInConfig=""   

function saveUserName(nodeId)
    if not nodeId or "string" ~= type(nodeId) then
        return
    end
    nodeIdInConfig = nodeId
    NodeIdConfig.saveValue(CloudConsts.NODE_ID,nodeId)
end

function savePassword(password)
    if not password or "string" ~= type(password) then
        return
    end
    passwordInConfig = password
    NodeIdConfig.saveValue(CloudConsts.PASSWORD,password)
end

function clearUserName()
    nodeIdInConfig=""
    Config.saveValue(CloudConsts.NODE_ID,"")
    NodeIdConfig.saveValue(CloudConsts.NODE_ID,"")
end

function clearPassword()
    passwordInConfig=""
    Config.saveValue(CloudConsts.PASSWORD,"")
    NodeIdConfig.saveValue(CloudConsts.PASSWORD,"")
end


function getUserName(allowDefault)
    if Consts.TEST_MODE then
        return MQTT_USER_NAME
    end


    if nodeIdInConfig and #nodeIdInConfig>0 then
        return nodeIdInConfig
    end

    --优先使用专用的文件
    nodeId = NodeIdConfig.getValue(CloudConsts.NODE_ID)
    if nodeId and #nodeId>0 then
        nodeIdInConfig= nodeId
        return nodeId
    end

    nodeId = Config.getValue(CloudConsts.NODE_ID)
    if nodeId and #nodeId>0 then
        nodeIdInConfig= nodeId
        return nodeId
    end

    if allowDefault then
        return MQTT_USER_NAME
    end
    return ""
end 

function getPassword(allowDefault)
    if Consts.TEST_MODE then
        return MQTT_PASSWORD
    end

    if passwordInConfig and #passwordInConfig>0 then
        return passwordInConfig
    end

    --优先使用专用的文件
    ps = NodeIdConfig.getValue(CloudConsts.PASSWORD)
    if ps and #ps>0 then
        passwordInConfig=ps
        return ps
    end

    ps = Config.getValue(CloudConsts.PASSWORD)
    if ps and #ps>0 then
        passwordInConfig=ps
        return ps
    end

    if allowDefault then
        return MQTT_PASSWORD
    end
    return ""
end

