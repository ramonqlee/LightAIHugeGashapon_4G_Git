
-- @module UARTControlInd
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2018.10.19

require "UARTUtils"

UARTShutDown={
	MT = 0x14
}

function UARTShutDown.encode( delayInSec)
	-- TODO待根据格式组装报文
 	data = pack.pack("l",delayInSec)
 	
 	sf = pack.pack("b",UARTUtils.SEND)
 	mt = pack.pack("b",UARTShutDown.MT)
 	addr = pack.pack("b3",0x0,0x0,0x0)
 	return UARTUtils.encode(sf,addr,mt,data)
end       


