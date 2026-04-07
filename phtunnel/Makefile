include $(TOPDIR)/rules.mk

PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Oray <developer@oray.com>
PKG_LICENSE:=Proprietary
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/phtunnel
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=3  Applications
  TITLE:=HSK Intranet penetration
  URL:=https://hsk.oray.com/
  DEPENDS:=+libc +libpthread +librt
  PKG_ARCH:=$(ARCH)
endef

define Package/phtunnel/description
  PHTunnel is core component of HSK intranet penetration, which can easily implement
  high-performance reverse proxy applications, supports TCP, HTTP, HTTPS protocols,
  end-to-end TLS encrypted communication, black and white list anti-black verification, etc.
  Through PHTunnel, external network devices can easily penetrate various complex routes
  and firewalls to access devices on internal network.
  
  This is pre-compiled binary package downloaded from Oray official mirrors.
endef

# No source code - this is a pre-compiled binary from Oray
define Build/Prepare
	$(INSTALL_DIR)
endef

# Since we're using pre-compiled binaries, just download and package
define Build/Compile
	# Download precompiled phtunnel binary from Oray mirrors
	
	$(info) Downloading precompiled phtunnel binary for $(PKG_ARCH)...
	
	case "$(PKG_ARCH)" in
		x86_64)
			BINARY_URL="https://mirrors.oray.com/orayos/packages/phtunnel/1.0.1/bin/phtunnel"
			BINARY_FILE="phtunnel"
			;;
		qualcommax-ipq807x|aarch64_cortex-a53)
			BINARY_URL="https://mirrors.oray.com/orayos/packages/phtunnel/1.0.1/bin/aarch64_cortex-a53/phtunnel"
			BINARY_FILE="phtunnel"
			;;
		*)
			BINARY_URL="https://mirrors.oray.com/orayos/packages/phtunnel/1.0.1/bin/$(PKG_ARCH)/phtunnel"
			BINARY_FILE="phtunnel"
			;;
	esac
	
	if [ ! -d "$(PKG_BUILD_DIR)" ]; then
		mkdir -p $(PKG_BUILD_DIR)
	fi
	
	echo "Downloading from: $BINARY_URL"
	
	if curl -fL "$BINARY_URL" -o $(PKG_BUILD_DIR)/phtunnel; then
		echo "Successfully downloaded phtunnel binary for $(PKG_ARCH)"
		chmod +x $(PKG_BUILD_DIR)/phtunnel
	else
			echo "Failed to download phtunnel binary for $(PKG_ARCH)"
		exit 1
	fi
endef

define Package/phtunnel/install
	$(INSTALL_DIR)/etc/init.d
	$(INSTALL_DIR)/etc/config
	$(INSTALL_DIR)/etc/hotplug.d/iface
	$(INSTALL_DIR)/usr/sbin
	$(INSTALL_DIR)/var/log/oraybox
	
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/phtunnel $(INSTALL_DIR)/usr/sbin/
	$(INSTALL_BIN) ./files/etc/init.d/phtunnel $(INSTALL_DIR)/etc/init.d/
	$(INSTALL_CONF) ./files/etc/config/phtunnel $(INSTALL_DIR)/etc/config/
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/30-oray-phtunnel $(INSTALL_DIR)/etc/hotplug.d/iface/
	
	mkdir -p $(INSTALL_DIR)/var/log/oraybox
endef

define Package/phtunnel/postinst
#!/bin/sh
# This package uses pre-compiled binaries from Oray
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

$(eval $(call BuildPackage))
