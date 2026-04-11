include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-phtunnel/install
	$(INSTALL_DIR) $(1)/usr/share/lua/luci/controller/oray
	$(INSTALL_DIR) $(1)/usr/share/lua/luci/model/cbi/oray
	$(INSTALL_DIR) $(1)/usr/share/lua/luci/view/oray
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/etc/config/phtunnel
endef

define Build/Compile
	true
endef

$(eval $(call BuildPackage,luci-app-phtunnel))