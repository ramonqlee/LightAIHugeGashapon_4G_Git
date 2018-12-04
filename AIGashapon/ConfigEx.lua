-- @module ConfigEx
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2017.12.23
-- tested 2017.12.27

require "LogUtil"
require "FileUtil"
require "Consts"

local jsonex=require "jsonex"

local TAG = "ConfigEx"
ConfigEx = {}

function ConfigEx.getValue(fileName,key)
	if not fileName or not key then
		return nil
	end
	-- --LogUtil.d(TAG,"config file name ="..ConfigEx.CONFIG_FILE)
	
	local content = FileUtil.readfile(fileName)

	if "string"==type(content) and #content>0 then 
		content= jsonex.decode(content)
	else
		content={}
	end

	if not content then
		return nil
	end

	return content[key]
end


function ConfigEx.saveValue(fileName,key,value)
	-- --LogUtil.d(TAG,"saveValue key = "..key.." value = "..value)
	if not fileName or not key then
		return
	end

	local content = FileUtil.readfile(fileName)

	if content and #content >0 then
		content = jsonex.decode(content)
	else
		content={}
	end

	if not content then
		content={}
		--LogUtil.d(TAG,"content is set to empty")
	end

	content[key]=value
	content = jsonex.encode(content)

	if not content then
		return
	end

	-- LogUtil.d(TAG,TAG.." config saveValue = "..content)

	FileUtil.writevalw(fileName,content)
end 


  