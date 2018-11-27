
-- @module UARTSlave
-- @author ramonqlee
-- @copyright idreems.com
-- @release 2017.12.29

require "UARTUtils"

UARTSlave={
	MT = 0xFE
}

-- boardId = v["id"]--3 bytes
-- group = v["group"]--1byte
-- color = v["color"]--1bye
-- time = v["time"]--2byte
function UARTSlave.encode()
	-- TODO待根据格式组装报文
 	data = pack.pack("b",0)--msgType=0

 	sf = pack.pack("b",UARTUtils.SEND)
 	addr = pack.pack("b3",0x0,0x0,0x0)
 	mt = pack.pack("b",UARTSlave.MT)
 	return UARTUtils.encode(sf,addr,mt,data)
end        


