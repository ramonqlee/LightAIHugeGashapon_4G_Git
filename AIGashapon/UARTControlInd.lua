
-- @module UARTControlInd
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2017.12.29
require "pins"
require "UARTUtils"
require "LogUtil"

local OPEN_VAL  = 0
local CLOSE_VAL = 1

--戳货检测
local myCallback = nil
local currentAddr = nil

local wd= pins.setup(pio.P0_27,CLOSE_VAL)--函数

local setGpio64Fnc = pins.setup(pio.P2_0,0)
UARTControlInd={
	MT = 0x12
}

function UARTControlInd.encode()
	-- TODO待根据格式组装报文
 	return pack.pack("b",0x55)
end  

function UARTControlInd.open()
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

function UARTControlInd.setDeliverCallback( addr,callback )
	myCallback = callback
	currentAddr = addr
end

function deliverDetector(msg)
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
      LogUtil.d(TAG,"deliver detecting")
    end
end

local getGpio28Fnc = pins.setup(pio.P0_28,deliverDetector)     


