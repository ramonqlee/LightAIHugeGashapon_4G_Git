-- @module MsgQueue
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2018.2.8

require "LogUtil"
require "Config"
require "MyUtils"

local jsonex = require "jsonex"

local MAX_MQTT_CACHE_COUNT = 30--缓存的最大数量
local DECR_MQTT_CACHE_COUNT = 5--超过条数后，每次删除的数量
local MSGQUEUE_KEY="msgQueue"

local TAG = "MSGQUEUE"

MsgQueue={}

function MsgQueue.clear()
    Config.saveValue(MSGQUEUE_KEY,"")
    LogUtil.d(TAG,"clear "..TAG)
end

function MsgQueue.size()
    return MyUtils.getTableLen(MsgQueue.getQueue())
end

function MsgQueue.hasMessage()
    return MsgQueue.size()>0
end

-- 获取所有的消息
function MsgQueue.getQueue()
    local mqttMsgSet = {}
    local allset = Config.getValue(MSGQUEUE_KEY)
    if allset and "string"==type(allset) and #allset>0 then
        mqttMsgSet = jsonex.decode(allset)
    end 

    if not mqttMsgSet then
        mqttMsgSet = {}
    end

    LogUtil.d(TAG,"getQueue,size = "..MsgQueue.size())
    return mqttMsgSet
end

function MsgQueue.remove(sn)
    if not sn or "string"~=type(sn) then
        return
    end

    local allMsg = MsgQueue.getQueue()
    allMsg[sn]=nil
    if 0 == MyUtils.getTableLen(allMsg) then
        MsgQueue.clear()
    else
        Config.saveValue(MSGQUEUE_KEY,jsonex.encode(allMsg))
    end
    LogUtil.d(TAG,"after remove,size = "..MsgQueue.size())
end

--添加到msg缓存,如果不存在，则返回true；如果已经存在，则返回false
function MsgQueue.add(sn,msg)
    if not sn or not msg then
        return
    end

    local mqttMsgSet = MsgQueue.getQueue()
    if not mqttMsgSet then
        mqttMsgSet = {}
    end
    mqttMsgSet[sn]=msg

    Config.saveValue(MSGQUEUE_KEY,jsonex.encode(mqttMsgSet))
    LogUtil.d(TAG,"after add,size = "..MsgQueue.size())
end     


