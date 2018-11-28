-- @module HugeOpenLock
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2017.12.24

--整体逻辑，在调用喂狗时，翻转电平

require "pins"
require "LogUtil"

local OPEN_VAL  = 0
local CLOSE_VAL = 1

local TAG = "OpenLock"

local wd= pins.setup(pio.P0_27,CLOSE_VAL)--函数
local setGpio64Fnc = pins.setup(pio.P2_0,0)
HugeOpenLock={}

function HugeOpenLock.open()
	if not wd or "function"~= type(wd) then
		return
	end

	LogUtil.d(TAG,"OpenLock")
	wd(OPEN_VAL)
	sys.timerStart(function()
		wd(CLOSE_VAL)
		LogUtil.d(TAG,"Close Lock")
	end,50)
end


--戳货检测
local myCallback = nil
local currentAddr = nil
function HugeOpenLock.setDeliverCallback( addr,callback )
	myCallback = callback
	currentAddr = addr
end

function deliverDetector(msg)
    LogUtil.d(TAG,"deliverDetector")

    if msg==cpu.INT_GPIO_NEGEDGE then
      LogUtil.d(TAG,"deliver detected")
      
      setGpio64Fnc(1)
      if not currentAddr or not myCallback then
      	return
      end

      if myCallback then
      	myCallback(currentAddr)

        --reset to prevent duplicate call
        currentAddr = nil
        myCallback  = nil
      end
    else
      setGpio64Fnc(0)
      LogUtil.d(TAG,"deliver not detected")
    end
end

local getGpio28Fnc = pins.setup(pio.P0_28,deliverDetector)

