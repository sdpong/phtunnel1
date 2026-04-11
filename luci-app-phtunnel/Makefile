include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=Oray <developer@oray.com>
PKG_TITLE:=LuCI interface for PHTunnel
PKG_DESCRIPTION:=Web interface for PHTunnel configuration and monitoring
PKG_DEPENDS:=+luci-base

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-phtunnel/conffiles
	/etc/config/phtunnel
endef

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
