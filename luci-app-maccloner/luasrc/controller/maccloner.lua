module("luci.controller.maccloner", package.seeall)

function index()
    entry({"admin", "network", "maccloner"}, cbi("maccloner"), _("MAC Cloner"), 30)
    entry({"admin", "network", "maccloner", "status"}, call("action_status"), _("Status"), 31).leaf = true
end

function action_status()
    local sys = require "luci.sys"
    local uci = require "luci.model.uci".cursor()

    local enabled = uci:get("maccloner", "settings", "enabled")

    local rules = {}
    uci:foreach("maccloner", "rule", function(s)
        local iface = s.interface
        local target_ssid = s.target_ssid or ""
        local custom_mac = s.custom_mac or ""
        local rule_enabled = s.enabled or "0"

        -- Get current MAC of the interface
        local current_mac = sys.exec("cat /sys/class/net/" .. iface .. "/address 2>/dev/null"):gsub("\n", "")
        -- Get current SSID if wireless
        local current_ssid = ""
        local is_wireless = false
        if sys.exec("iwinfo " .. iface .. " info 2>/dev/null") ~= "" then
            is_wireless = true
            current_ssid = sys.exec("iwinfo " .. iface .. " info | sed -n 's/.*SSID: \"\\(.*\\)\"/\\1/p'"):gsub("\n", "")
        end
        local match = (current_mac ~= "" and custom_mac ~= "" and current_mac:lower() == custom_mac:lower())

        rules[#rules+1] = {
            iface = iface,
            target_ssid = target_ssid,
            custom_mac = custom_mac,
            rule_enabled = rule_enabled,
            current_mac = current_mac,
            current_ssid = current_ssid,
            is_wireless = is_wireless,
            match = match
        }
    end)

    luci.template.render("maccloner/status", {
        service_enabled = enabled,
        rules = rules
    })
end
