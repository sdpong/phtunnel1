include $(TOPDIR)/rules.mk

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
	if [ -n "$(BINARY_ARCH)" ]; then \
		BINARY_FILE="$(CURDIR)/binaries/$(BINARY_ARCH)/phtunnel"; \
		if [ -f "$$$$BINARY_FILE" ]; then \
			cp "$$$$BINARY_FILE" "$(PKG_BUILD_DIR)/phtunnel"; \
			chmod +x "$(PKG_BUILD_DIR)/phtunnel"; \
			echo "Successfully copied phtunnel binary for $(BINARY_ARCH)"; \
		else \
			echo "Error: phtunnel binary not found: $(BINARY_ARCH)"; \
			echo "Looking for: $$$$BINARY_FILE"; \
			ls -la "$(CURDIR)/binaries/"; \
			exit 1; \
		fi \
	else \
		echo "Error: BINARY_ARCH environment variable not set"; \
		echo "Available binaries:"; \
		ls -la "$(CURDIR)/binaries/"; \
		exit 1; \
	fi
endef

define Build/Configure
	true
endef

define Build/Compile
	true
endef

define Package/phtunnel/preinst
#!/bin/sh
exit 0
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

define Package/phtunnel/postinst
#!/bin/sh
/etc/init.d/phtunnel enable
/etc/init.d/phtunnel restart
endef

$(eval $(call BuildPackage,phtunnel))
