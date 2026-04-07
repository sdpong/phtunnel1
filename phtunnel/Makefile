include $(TOPDIR)/rules.mk

# OpenWrt 25.12.x 包变量
PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=2

# 架构映射
# 将 OpenWrt 目标架构映射到本地二进制文件架构
ifeq ($(ARCH),x86_64)
  BINARY_ARCH:=x86_64
else ifeq ($(ARCH),aarch64)
  BINARY_ARCH:=aarch64
else ifeq ($(ARCH),armv7)
  BINARY_ARCH:=armv7
else ifeq ($(ARCH),arm_cortex-a7)
  BINARY_ARCH:=armv7
else ifeq ($(ARCH),arm_cortex-a9)
  BINARY_ARCH:=armv7
else ifeq ($(ARCH),mips)
  BINARY_ARCH:=mips
else ifeq ($(ARCH),mips_24kc)
  BINARY_ARCH:=mips
else ifeq ($(ARCH),mipsel)
  BINARY_ARCH:=mipsel
else ifeq ($(ARCH),mipsel_24kc)
  BINARY_ARCH:=mipsel
else
  BINARY_ARCH:=x86_64  # 默认使用 x86_64
endif

# 本地二进制文件路径
BINARY_DIR:=$(CURDIR)/binaries/$(BINARY_ARCH)

# 源代码信息
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
	# 复制对应架构的二进制文件
	if [ -f "$(BINARY_DIR)/phtunnel" ]; then \
		cp $(BINARY_DIR)/phtunnel $(PKG_BUILD_DIR)/phtunnel; \
		chmod +x $(PKG_BUILD_DIR)/phtunnel; \
		echo "Using phtunnel binary for $(BINARY_ARCH)"; \
	else \
		echo "Error: phtunnel binary not found for $(BINARY_ARCH)"; \
		exit 1; \
	fi
endef

define Build/Compile
	# 二进制文件已经预编译，无需重新编译
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