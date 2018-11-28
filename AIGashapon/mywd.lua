-- @module Consts
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2017.12.24

--整体逻辑，在调用喂狗时，翻转电平

require "pins"
require "LogUtil"

local wd_val=0--上次喂狗的电平
local wd=nil--喂狗函数
local TAG = "MYWD"
mywd={}

local function init()

end

function mywd.feed()
	
end


