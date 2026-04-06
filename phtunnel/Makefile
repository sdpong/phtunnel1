include $(TOPDIR)/rules.mk

# OpenWrt 25.12.x 包变量
PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

# 源代码信息
PKG_SOURCE:=phtunnel
PKG_SOURCE_URL:=https://mirrors.oray.com/orayos/packages/$(PKG_NAME)/$(PKG_VERSION)/bin
PKG_HASH:=skip
PKG_FLAGS:=nonshared
PKG_MAINTAINER:=Oray <developer@oray.com>
PKG_LICENSE:=Proprietary

# 使用标准 package.mk
include $(INCLUDE_DIR)/package.mk

define Package/phtunnel
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=@(arm||aarch64||mips||mipsel||i386||x86_64) \
    +libc +libpthread +librt
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
	cp $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)
	chmod +x $(PKG_BUILD_DIR)/$(PKG_SOURCE)
endef

define Build/Compile
	true
endef

define Package/phtunnel/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/usr/sbin

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/phtunnel $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/etc/init.d/* $(1)/etc/init.d/
	$(INSTALL_CONF) ./files/etc/config/* $(1)/etc/config/
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/* $(1)/etc/hotplug.d/iface/
endef

$(eval $(call BuildPackage,phtunnel))
