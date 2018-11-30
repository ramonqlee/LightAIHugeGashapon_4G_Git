
-- @module UARTControlInd
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2017.12.29
require "pins"
require "UARTUtils"
require "LogUtil"

--戳货检测
local myCallback = nil
local currentAddr = nil

local setGpio64Fnc = pins.setup(pio.P2_0,0)
UARTControlInd={
	MT = 0x12
}

function UARTControlInd.encode()
	-- TODO待根据格式组装报文
 	return pack.pack("b",0x55)
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


