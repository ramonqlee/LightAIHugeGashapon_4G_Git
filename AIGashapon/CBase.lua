-- @module CBase
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2017.12.21
-- tested 2017.12.27

require "LogUtil"
require "CloudConsts"
require "Consts"

local jsonex = require "jsonex"

CBase = {
  mTimestampInSec=0
}

local TAG = "CBase"

function CBase:new(o)
  	o = o or {}
  	setmetatable(o, self)
  	self.__index = self
  	return o
end

function CBase:handle( obj )
    if Consts.LOG_ENABLED then
      collectgarbage("collect")
      c = collectgarbage("count")
      --LogUtil.d("Mem","CBase:handle memory count ="..c)
    end

    -- --LogUtil.d(TAG,TAG.." handle now")


    local r = false
    if (not obj) then
      --LogUtil.d(TAG,TAG.." handle empty object")
      return r
    end

    local tableObj = obj
    if "string"==type(tableObj) then
      tableObj = jsonex.decode(obj)
    end

    if "table"~=type(tableObj) then
      --LogUtil.d(TAG,type(obj)..",non table object,return")
      return r
    end
    
    payloadJson = self:match(string.format("%s/%s",MyUtils.getUserName(),self:name()),tableObj)

    if not payloadJson then
      --LogUtil.d(TAG,TAG.." handle empty payload,return")
      return r
    end

    -- --LogUtil.d(TAG,TAG.." handle payload now = "..jsonex.encode(payloadJson).." type="..type(payloadJson))
    self.mTimestampInSec = payloadJson[CloudConsts.TIMESTAMP]
    
    if not self.mTimestampInSec and self.mTimestampInSec < 0 then
      self.mTimestampInSec = 0
    end

    -- if ( string.upper(self:name()) == string.upper(RepTime.MY_TOPIC) ) then
    local mycontent=payloadJson[CloudConsts.CONTENT]
    local arriveTime = tableObj[CloudConsts.ARRIVE_TIME]--指令到达的时间
    if arriveTime then
      mycontent[CloudConsts.ARRIVE_TIME] = arriveTime
    end

    --LogUtil.d(TAG,TAG.." handle "..CloudConsts.CONTENT.." = "..type(mycontent).." at "..self.mTimestampInSec)
    if ( string.upper(self:name()) == string.upper("reply_time") ) then
      return self:handleContent(self.mTimestampInSec, mycontent)
    end

    return self:handleContent(mycontent)
end

function CBase:handleContent( contentJson )
end 

function CBase:handleContent( timestamp,contentJson )
end 

function CBase:match(topic,object)
    if not topic or not object then
      return nil
    end

    r = object[CloudConsts.TOPIC]

    if not r then
      --LogUtil.d(TAG,TAG.." CBase:match, empty object,return false")
      return nil
    end

      -- --LogUtil.d(TAG,TAG.." match topic="..topic.." with "..r)
    local m,_=string.find(string.upper(r),string.upper(topic))
    if  nil ~= m  then
      -- --LogUtil.d(TAG,TAG.." match name = "..self:name())
      r = object[CloudConsts.PAYLOAD]
      if "string"==type(r) then
        return jsonex.decode(r)
      end
    end
    
    return nil
end    



