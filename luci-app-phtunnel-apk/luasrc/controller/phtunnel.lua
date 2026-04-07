module("luci.controller.phtunnel", package.seeall)

function index()
    entry({"admin", "services", "phtunnel"}, cbi("phtunnel"), _("PHTunnel"), 60).dependent = false
end
