-- @module SnCache
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2018.2.8

require "LogUtil"
require "ConfigEx"
require "MyUtils"

local jsonex = require "jsonex"

local CONFIG_FILE = Consts.USER_DIR.."/sncache.data"
local MAX_MQTT_CACHE_COUNT = 15--缓存的最大数量
local DECR_MQTT_CACHE_COUNT = 5--超过条数后，每次删除的数量
local SN_SET_PERSISTENCE_KEY="sncache"

local inited = false
local TAG = "MSGCACHE"
local memCache = {}
SnCache={}

function SnCache.init()
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
end


function SnCache.clear()
    memCache={}
    ConfigEx.saveValue(CONFIG_FILE,SN_SET_PERSISTENCE_KEY,"")
    LogUtil.d(TAG,"clear SnCache")
end

function SnCache.remove(sn)
    if not sn or "string"~=type(sn) then
        return
    end
    SnCache.init()

    if not memCache then
        memCache={}
    end

    LogUtil.d(TAG,"start to remove msg,sn ="..sn)
    memCache[sn]=nil

    ConfigEx.saveValue(CONFIG_FILE,SN_SET_PERSISTENCE_KEY,jsonex.encode(memCache))
    LogUtil.d(TAG,sn.."reduce queue's sn = "..sn.." new size="..MyUtils.getTableLen(memCache).." sn ="..sn)
end

function SnCache.getMessageSn( msg )
    local tableObj = msg
    if "string"==type(tableObj) then
        tableObj = jsonex.decode(msg)
    end

    if not tableObj or "table"~=type(tableObj) then
        return nil
    end

    local payload = tableObj[CloudConsts.PAYLOAD]
    if "string"==type(payload) then
      payload = jsonex.decode(payload)
    end

    if not payload or "table" ~= type(payload) then
        return nil
    end


    local content = payload[CloudConsts.CONTENT]
    if not content or "table" ~= type(content) then
        return nil
    end

    local sn = content[CloudConsts.SN]

    if not sn or "string"~= type(sn) then
        return nil
    end
    return sn
end

function SnCache.hasMessage( msg )
    if not msg or "string"~=type(msg) then
        return false
    end

    SnCache.init()
    LogUtil.d(TAG,"SnCache.hasMessage = "..msg)
    local sn = SnCache.getMessageSn(msg)
    if not sn then
        return false
    end

    return nil~=memCache[sn]
end


--添加到msg缓存,如果不存在，则返回true；如果已经存在，则返回false
function SnCache.addMsg2Cache(msg)
    --解析msg中的sn
    if not msg then
        return false
    end
    SnCache.init()

    local sn = SnCache.getMessageSn(msg)
    if not sn then
        LogUtil.d(TAG,sn.." no sn,ignore")
        return false
    end
    memCache[sn]=sn

    --是否需要更新文件
    ConfigEx.saveValue(CONFIG_FILE,SN_SET_PERSISTENCE_KEY,jsonex.encode(memCache))
    LogUtil.d(TAG,sn.." update queue,size="..MyUtils.getTableLen(memCache).." sn ="..sn)

    return true
end     


