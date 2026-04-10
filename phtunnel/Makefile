
include $(TOPDIR)/rules.mk

# Package metadata
PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=2
PKG_HASH:=skip
PKG_FLAGS:=nonshared
PKG_MAINTAINER:=Oray <developer@oray.com>
PKG_LICENSE:=Proprietary

include $(INCLUDE_DIR)/package.mk

define Package/phtunnel
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=+libc +libpthread +librt
  TITLE:=HSK Intranet penetration
  URL:=https://hsk.oray.com/
  MAINTAINER:=Oray <developer@oray.com>
  LICENSE:=Proprietary
endef

define Package/phtunnel/description
    PHTunnel is core component of HSK intranet penetration, which can easily implement high-performance
    reverse proxy applications, supports TCP, HTTP, HTTPS protocols, end-to-end TLS encrypted communication,
    black and white list anti-black verification, etc. Through PHTunnel, external network devices can easily
    penetrate various complex routes and firewalls to access devices on internal network.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/phtunnel/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/phtunnel $(1)/usr/sbin/
endef

define Package/phtunnel/postinst
#!/bin/sh
/etc/init.d/phtunnel enable
/etc/init.d/phtunnel restart
exit 0
endef

$(eval $(call BuildPackage,phtunnel))