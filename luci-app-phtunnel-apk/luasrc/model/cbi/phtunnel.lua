m = Map("phtunnel", translate("PHTunnel"), translate("HSK Intranet Penetration Service"))

m:section(SimpleSection).template = "phtunnel/phtunnel_status"

s = m:section(TypedSection, "phtunnel", translate("Basic Settings"))
s.anonymous = true
s.addremove = false

enabled = s:option(Flag, "enabled", translate("Enabled"))
enabled.rmempty = false

sn = s:option(Value, "sn", translate("SN"), translate("Device SN"))
sn.rmempty = false

user = s:option(Value, "user", translate("User"), translate("Device User"))
user.rmempty = false

s = m:section(TypedSection, "proxy", translate("Proxy Settings"))
s.addremove = true
s.anonymous = true

s:option(Value, "port", translate("Port"))
s:option(Value, "protocol", translate("Protocol"))
s:option(Value, "host", translate("Host"))

return m
