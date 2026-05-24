module("luci.controller.maccloner", package.seeall)

function index()
    entry({"admin", "network", "maccloner"}, cbi("maccloner"), _("MAC Cloner"), 30)
end
