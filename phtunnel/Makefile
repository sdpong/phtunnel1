include $(TOPDIR)/rules.mk

PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_TITLE:=PHTunnel - HSK Intranet Penetration Tool
PKG_DESCRIPTION:=HSK intranet penetration tool for OpenWrt routers, enabling secure remote access without port forwarding
PKG_SECTION:=net
PKG_CATEGORY:=Network
PKG_URL:=https://github.com/oray/phtunnel
PKG_MAINTAINER:=Oray <developer@oray.com>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/phtunnel/conffiles
	/etc/config/phtunnel
endef

define Package/phtunnel/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) ./binaries/aarch64/phtunnel $(1)/usr/sbin/
endef

define Package/phtunnel/description
	PHTunnel provides HSK intranet penetration functionality for OpenWrt routers, enabling secure remote access without port forwarding.
endef

define Package/phtunnel/postinst
#!/bin/sh
	/etc/init.d/phtunnel enable
	/etc/init.d/phtunnel restart
	exit 0
endef

define Package/phtunnel/prerm
#!/bin/sh
	/etc/init.d/phtunnel disable
	/etc/init.d/phtunnel stop
	exit 0
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
	# Direct binary copy without complex dependencies
	if [ -f "./binaries/aarch64/phtunnel" ]; then \
		cp ./binaries/aarch64/phtunnel $(PKG_BUILD_DIR)/phtunnel; \
		chmod +x $(PKG_BUILD_DIR)/phtunnel; \
	else \
		echo "ERROR: phtunnel binary not found for aarch64"; \
		exit 1; \
	fi
endef

$(eval $(call BuildPackage,phtunnel))