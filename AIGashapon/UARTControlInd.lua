
-- @module UARTControlInd
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2017.12.29

require "UARTUtils"

UARTControlInd={
	MT = 0x12
}

function UARTControlInd.encode()
	-- TODO待根据格式组装报文
 	return pack.pack("b",0x55)
end       


