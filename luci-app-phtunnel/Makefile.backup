include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=Oray <developer@oray.com>

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-phtunnel/compile
	# LuCI applications don't need compilation, just file copying
	true
endef

define Package/luci-app-phtunnel/postinst
	#!/bin/sh
	/etc/init.d/phtunnel enable >/dev/null 2>&1 || true
	exit 0
endef

define Package/luci-app-phtunnel/prerm
	#!/bin/sh
	/etc/init.d/phtunnel disable >/dev/null 2>&1 || true
	exit 0
endef

define Package/luci-app-phtunnel/postrm
	#!/bin/sh
	/etc/init.d/phtunnel stop >/dev/null 2>&1 || true
	exit 0
endef

$(eval $(call BuildPackage,luci-app-phtunnel))