-- @module NodeIdConfig
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2017.12.23
-- tested 2017.12.27

require "Consts"
require "ConfigEx"


local TAG = "NodeIdConfig"
NodeIdConfig = {}

local CONFIG_FILE = Consts.USER_DIR.."/nodeid_config.dat"

function NodeIdConfig.getValue(key)
	return ConfigEx.getValue(CONFIG_FILE,key)
end

function NodeIdConfig.saveValue(key,value)
	ConfigEx.saveValue(CONFIG_FILE,key,value)
end  

 