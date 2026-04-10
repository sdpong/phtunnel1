include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-phtunnel/postinst
#!/bin/sh
	/etc/init.d/luci-app-phtunnel enable
	exit 0
endef

define Package/luci-app-phtunnel/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/usr/sbin/
endef

define Package/luci-app-phtunnel/postprerm
#!/bin/sh
	/etc/init.d/luci-app-phtunnel disable
	exit 0
endef

define Package/luci-app-phtunnel/prerm
	#!/bin/sh
	/etc/init.d/luci-app-phtunnel disable
	exit 0
endef

define Build/Compile
	# LuCI applications don't need compilation, just file copying
	true
endef

$(eval $(call BuildPackage,luci-app-phtunnel))