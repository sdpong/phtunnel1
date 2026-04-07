include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=3

LUCI_TITLE:=LuCI Support for PHTunnel
LUCI_DEPENDS:=+cgi-io +curl +luci-lib-jsonc +phtunnel
LUCI_PKGARCH:=all

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=$(LUCI_TITLE)
  URL:=https://github.com/sdpong/phtunnel1
  MAINTAINER:=Oray <developer@oray.com>
  LICENSE:=GPL-2.0-only
  DEPENDS:=$(LUCI_DEPENDS)
  ARCH:=all
endef

define Package/$(PKG_NAME)/description
  LuCI web interface for PHTunnel (HSK intranet penetration).
  This package provides a web interface for configuring and managing
  PHTunnel services in OpenWrt.
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/oray
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/oray
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/oray
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DIR) $(1)/usr/share/luci/i18n

	$(CP) $(PKG_BUILD_DIR)/luasrc/* $(1)/usr/lib/lua/luci/
	$(CP) $(PKG_BUILD_DIR)/root/* $(1)/
endef

define Package/luci-app-phtunnel/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
    rm -rf /tmp/luci-* /tmp/ucimapcache
    (exit 0)
fi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))