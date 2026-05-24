local m = Map("maccloner", translate("MAC Cloner"),
    translate("Configure custom MAC addresses for wireless client interfaces."))

local s = m:section(TypedSection, "global", translate("Global Settings"))
s.addremove = false
s:option(Flag, "enabled", translate("Enable"), translate("Enable MAC Cloner service"))

local r = m:section(TypedSection, "rule", translate("MAC Cloner Rules"),
    translate("Define interfaces, target SSIDs, and custom MAC addresses."))
r.addremove = true
r.template = "cbi/tblsection"

-- Allowed any string, including hyphens
r:option(Value, "interface", translate("Interface")).datatype = "string"

r:option(Value, "target_ssid", translate("Target SSID (optional)"))
r:option(Value, "custom_mac", translate("Custom MAC Address"))
r:option(Flag, "enabled", translate("Enabled"))

return m
