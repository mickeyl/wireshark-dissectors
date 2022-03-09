-- HSFZ UDP protocol framer. (C) Dr. Michael 'Mickey' Lauer <mlauer@vanille-media.de>

hsfz_protocol = Proto("HSFZ.d",  "BMW High-Speed-Fahrzeug-Zugang (High Speed Vehicle Access) [DISCOVERY]")

hsfz_protocol.fields = {}

function get_message_type(type)
    local name = "Unknown"

        if type == 0x0001 then name = "MESSAGE"
    elseif type == 0x0002 then name = "ECHO"
    elseif type == 0x0040 then name = "INVALID ADDRESS"
    elseif type == 0x0041 then name = "PROTOCOL VIOLATION"
       end

    return name
  end

function hsfz_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end
  pinfo.cols.protocol = "HSFZ"

  if length == 6 then
    pinfo.cols.info = "HSFZ Vehicle Announcement Request"
    local subtree = tree:add(hsfz_protocol, buffer(), "HSFZ Vehicle Announcement Request Data")
    subtree:add(length, buffer(0,6))
  end

  if length == 56 then
    pinfo.cols.info = "HSFZ Vehicle Announcement"
    local subtree = tree:add(hsfz_protocol, buffer(), "HSFZ Vehicle Announcement Data")
    subtree:add(length, buffer(0,56))
  end

  pinfo.cols.protocol = hsfz_protocol.name

end

local port = DissectorTable.get("udp.port")
port:add(6811, hsfz_protocol)
