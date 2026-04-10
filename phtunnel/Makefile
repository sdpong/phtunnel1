include $(TOPDIR)/rules.mk

PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=3

PKG_TITLE:=PHTunnel - HSK Intranet Penetration Tool

include $(INCLUDE_DIR)/package.mk

define Package/phtunnel/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/usr/sbin/
endef

define Package/phtunnel/postinst
#!/bin/sh
	/etc/init.d/phtunnel enable
	/etc/init.d/phtunnel restart
	exit 0
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
	if [ -n "$(BINARY_ARCH)" ]; then \
		if [ -f ./binaries/$(BINARY_ARCH)/phtunnel ]; then \
			cp ./binaries/$(BINARY_ARCH)/phtunnel $(PKG_BUILD_DIR)/phtunnel; \
		else \
			echo "ERROR: No binary found for architecture $(BINARY_ARCH)"; \
			exit 1; \
		fi \
	else \
		echo "ERROR: BINARY_ARCH environment variable not set"; \
		exit 1; \
	fi
	chmod +x $(PKG_BUILD_DIR)/phtunnel
endef

$(eval $(call BuildPackage,phtunnel))