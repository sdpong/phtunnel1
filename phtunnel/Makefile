include $(TOPDIR)/rules.mk

# OpenWrt 25.12.x 包变量
PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=2

# 本地二进制文件路径
BINARY_DIR:=$(CURDIR)/binaries

# 直接的架构检查，使用简单的逻辑
# 支持：x86, x86_64, aarch64, armv7, mips, mipsel
# OpenWrt 25.12.x SDK中实际的$(ARCH)变量值：

# 检查x86
if [ "$(ARCH)" = "x86" ]; then
  BINARY_ARCH:=x86_64
  # 检查x86_64
elif [ "$(ARCH)" = "x86_64" ]; then
  BINARY_ARCH:=x86_64
  # 检查aarch64
elif [ "$(ARCH)" = "aarch64" ]; then
  BINARY_ARCH:=aarch64
  # 检查armv7
elif [ "$(ARCH)" = "armv7" ]; then
  BINARY_ARCH:=armv7
  # 检查mips
elif [ "$(ARCH)" = "mips" ]; then
  BINARY_ARCH:=mips
  # 检查mipsel
elif [ "$(ARCH)" = "mipsel" ]; then
  # 检查arm_cortex-a7 (armv7)
  BINARY_ARCH:=armv7
  # 检查arm_cortex-a9 (armv7)
elif [ "$(ARCH)" = "arm_cortex-a7" ]; then
  BINARY_ARCH:=armv7
  # 检查arm_cortex-a9 (armv7)
elif [ "$(ARCH)" = "arm_cortex-a9" ]; then
  BINARY_ARCH:=armv7
  # 检查mips_24kc
elif [ "$(ARCH)" = "mips_24kc" ]; then
  BINARY_ARCH:=mips
  # 检查mipsel_24kc
elif [ "$(ARCH)" = "mipsel_24kc" ]; then
  BINARY_ARCH:=mipsel
  # 检查ath79 (mips)
elif [ "$(ARCH)" = "ath79" ]; then
  BINARY_ARCH:=mips
  # 检查rockchip (aarch64)
elif [ "$(ARCH)" = "rockchip" ]; then
  BINARY_ARCH:=aarch64
  # 检查bcm27xx (armv7)
elif [ "$(ARCH)" = "bcm27xx" ]; then
  BINARY_ARCH:=armv7
  # 其他
else
  BINARY_ARCH:=x86_64
endif

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
  
  # 检查本地二进制文件
  BINARY_FILE="$(BINARY_DIR)/$(BINARY_ARCH)/phtunnel"
  
  if [ -f "$(BINARY_FILE)" ]; then
    echo "Using phtunnel binary for $(BINARY_ARCH)"
    cp "$(BINARY_FILE)" "$(PKG_BUILD_DIR)/phtunnel"
    chmod +x "$(PKG_BUILD_DIR)/phtunnel"
  else
    echo "Error: phtunnel binary not found for $(BINARY_ARCH)"
    echo "Available binary architectures:"
    ls -la "$(BINARY_DIR)"/
    exit 1
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