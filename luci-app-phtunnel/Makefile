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
	$(INSTALL_DIR) $(1)/usr/share/lua/luci/controller/oray
	$(INSTALL_DIR) $(1)/usr/share/lua/luci/model/cbi/oray
	$(INSTALL_DIR) $(1)/usr/share/lua/luci/view/oray
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d/
endef

define Package/luci-app-phtunnel/postinst
#!/bin/sh
	exit 0
endef

define Build/Compile
	# LuCI applications don't need compilation, just file copying
	true
endef

$(eval $(call BuildPackage,luci-app-phtunnel))