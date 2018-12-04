-- @module MsgQueue
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2018.2.8

require "LogUtil"
require "ConfigEx"
require "MyUtils"

local jsonex = require "jsonex"

local CONFIG_FILE = Consts.USER_DIR.."/msgqueue.data"
local MAX_MQTT_CACHE_COUNT = 15--缓存的最大数量
local DECR_MQTT_CACHE_COUNT = 5--超过条数后，每次删除的数量
local MSGQUEUE_KEY="msgqueue"

local TAG = "MSGQUEUE"

local inited=false
local memCache = {}
MsgQueue={}

function MsgQueue.clear()
    memCache={}
    ConfigEx.saveValue(CONFIG_FILE,MSGQUEUE_KEY,"")
    LogUtil.d(TAG,"clear "..TAG)
end

function MsgQueue.size()
    MsgQueue.init()
    return MyUtils.getTableLen(memCache)
end

function MsgQueue.hasMessage()
    MsgQueue.init()
    return MyUtils.getTableLen(memCache)>0
end

-- 获取所有的消息
function MsgQueue.getQueue()
    MsgQueue.init()
    LogUtil.d(TAG,"getQueue,size = "..MsgQueue.size())
    return memCache
end

function MsgQueue.remove(sn)
    if not sn or "string"~=type(sn) then
        return
    end
    MsgQueue.init()

    memCache[sn]=nil
    ConfigEx.saveValue(CONFIG_FILE,MSGQUEUE_KEY,jsonex.encode(memCache))
    LogUtil.d(TAG,"after removing,size = "..MsgQueue.size().." sn ="..sn)
end

--添加到msg缓存,如果不存在，则返回true；如果已经存在，则返回false
function MsgQueue.add(sn,msg)
    if not sn or not msg then
        return
    end
    MsgQueue.init()
    if memCache[sn] then
        LogUtil.d(TAG,"MsgQueue.add  dup sn = "..sn)
        return
    end

    LogUtil.d(TAG," MsgQueue.add sn= "..sn)
    memCache[sn]=msg
    ConfigEx.saveValue(CONFIG_FILE,MSGQUEUE_KEY,jsonex.encode(memCache))
    LogUtil.d(TAG,"after addition,size = "..MsgQueue.size().." sn="..sn)
end   

function MsgQueue.init()
    if inited then
        return
    end
    -- TODO 读取文件
    
    local allset = ConfigEx.getValue(CONFIG_FILE,MSGQUEUE_KEY)
    if allset and "string"==type(allset) and #allset>0 then
        memCache = jsonex.decode(allset)
    end 

    if not memCache then
        memCache = {}
    end 
    inited = true
    LogUtil.d(TAG," MsgQueue.init")
end


