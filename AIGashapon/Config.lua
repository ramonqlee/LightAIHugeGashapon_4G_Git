-- @module Config
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2017.12.23
-- tested 2017.12.27

require "LogUtil"
require "Consts"
require "ConfigEx"

local jsonex=require "jsonex"

local TAG = "Config"
Config = {}

CONFIG_FILE = Consts.USER_DIR.."/nqconfig.txt"

function Config.getValue(key)
	return ConfigEx.getValue(CONFIG_FILE,key)
end


function Config.saveValue(key,value)
	ConfigEx.saveValue(CONFIG_FILE,key,value)
end 


  