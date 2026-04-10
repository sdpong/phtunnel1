include $(TOPDIR)/rules.mk

PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=3

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
	# Copy the appropriate binary based on architecture
	if [ -n "$(BINARY_ARCH)" ]; then \
		if [ -f ./binaries/$(BINARY_ARCH)/phtunnel ]; then \
			cp ./binaries/$(BINARY_ARCH)/phtunnel $(PKG_BUILD_DIR)/phtunnel; \
		else \
			echo "ERROR: No binary found for architecture $(BINARY_ARCH)"; \
			echo "Available architectures:"; \
			ls -la ./binaries/; \
			exit 1; \
		fi \
	else \
		echo "ERROR: BINARY_ARCH environment variable not set"; \
		exit 1; \
	fi
	chmod +x $(PKG_BUILD_DIR)/phtunnel
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/phtunnel
endef

define Build/Clean
	rm -rf $(PKG_BUILD_DIR)
endef

$(eval $(call BuildPackage))