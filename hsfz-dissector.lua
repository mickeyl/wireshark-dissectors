-- HSFZ protocol framer. (C) Dr. Michael 'Mickey' Lauer <mlauer@vanille-media.de>

hsfz_protocol = Proto("HSFZ",  "BMW High-Speed-Fahrzeug-Zugang (High Speed Vehicle Access)")

message_length = ProtoField.uint32("hsfz.message_length", "Message Length", base.DEC)
message_type = ProtoField.uint16("hsfz.message_type", "Message Type", base.DEC_HEX)
source_address = ProtoField.uint8("hfsz.source_address", "Source Address", base.DEC_HEX)
dest_address = ProtoField.uint8("hfsz.dest_address", "Destination Address", base.DEC_HEX)

hsfz_protocol.fields = {
    message_length,
    message_type,
    source_address,
    dest_address
}

function get_message_type(type)
    local name = "Unknown"

        if type == 0x0001 then name = "MESSAGE"
    elseif type == 0x0002 then name = "ECHO"
    elseif type == 0x0041 then name = "PROTOCOL VIOLATION"
     end

    return name
  end

function hsfz_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = hsfz_protocol.name

  local subtree = tree:add(hsfz_protocol, buffer(), "HSFZ Protocol Header")
  subtree:add(message_length, buffer(0,4))

  local mtype = buffer(4,2):int()
  local mtypename = get_message_type(mtype)
  subtree:add(message_type, buffer(4,2)):append_text(" (" .. mtypename .. ")")
  subtree:add(source_address, buffer(6,1))
  subtree:add(dest_address, buffer(7,1))

  uds_dissector = Dissector.get("uds")
  uds_dissector:call(buffer(8):tvb(), pinfo, tree)

end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(6801, hsfz_protocol)
