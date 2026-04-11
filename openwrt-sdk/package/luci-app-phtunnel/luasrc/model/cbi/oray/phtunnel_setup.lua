local m = Map("phtunnel", translate("PHTunnel"))

m:section(SimpleSection).template = "oray/phtunnel_status"

s = m:section(NamedSection, "base", "base", translate("Base Setup"))

o = s:option(Flag, "enabled", translate("Enabled"))
o.default = o.disabled
o.rmempty = false

function m.on_after_commit()
	luci.sys.exec("/etc/init.d/phtunnel restart >/dev/null 2>&1")
end

return m
