include $(TOPDIR)/rules.mk

PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=3

PKG_SOURCE:=phtunnel
PKG_SOURCE_URL:=https://mirrors.oray.com/orayos/packages/$(PKG_NAME)/$(PKG_VERSION)/bin
PKG_HASH:=skip
PKG_FLAGS:=nonshared
PKG_MAINTAINER:=Oray <developer@oray.com>
PKG_LICENSE:=Proprietary

include $(INCLUDE_DIR)/package.mk

define Package/phtunnel
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=HSK Intranet penetration
  URL:=https://hsk.oray.com/
  MAINTAINER:=Oray <developer@oray.com>
  LICENSE:=Proprietary
  DEPENDS:=@(arm||aarch64||mips||mipsel||i386||x86_64) \
    +libc +libpthread +librt
endef

define Package/phtunnel/description
  PHTunnel is core component of HSK intranet penetration, which can easily implement
  high-performance reverse proxy applications, supports TCP, HTTP, HTTPS protocols,
  end-to-end TLS encrypted communication, black and white list anti-black verification, etc.
  Through PHTunnel, external network devices can easily penetrate various complex routes
  and firewalls to access devices on internal network.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/
	chmod +x $(PKG_BUILD_DIR)/$(PKG_SOURCE)
endef

define Build/Compile
	$(TARGET_CC) -o $(PKG_BUILD_DIR)/phtunnel_check $(PKG_BUILD_DIR)/phtunnel 2>/dev/null || true
endef

define Package/phtunnel/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/var/log/oraybox

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/phtunnel $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/etc/init.d/phtunnel $(1)/etc/init.d/
	$(INSTALL_CONF) ./files/etc/config/phtunnel $(1)/etc/config/
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/30-oray-phtunnel $(1)/etc/hotplug.d/iface/
endef

define Package/phtunnel/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
    (exit 0)
fi
endef

define Package/phtunnel/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
    /etc/init.d/phtunnel stop >/dev/null 2>&1 || true
    (exit 0)
fi
endef

$(eval $(call BuildPackage,phtunnel))