include $(TOPDIR)/rules.mk

# OpenWrt 25.12.x APK 包变量
PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=2

include $(INCLUDE_DIR)/target.mk

# 架构检测逻辑
ifeq ($(ARCH),arm)
  ifneq ($(findstring $(CPU_SUBTYPE), neon neon-vfpv4 vfpv3),)
    PKG_ARCH_PHT:=arm_$(CPU_TYPE)_$(CPU_SUBTYPE)-$(LIBC)-unknown
  else ifneq ($(findstring $(CPU_TYPE), cortex-a9),)
    PKG_ARCH_PHT:=arm_cortex-a9-$(LIBC)-unknown
  else
    PKG_ARCH_PHT:=arm_cortex-a7-$(LIBC)-unknown
  endif
endif

ifeq ($(ARCH),aarch64)
  ifneq ($(findstring $(CPU_TYPE), cortex-a53 cortex-a72),)
    PKG_ARCH_PHT:=aarch64_$(CPU_TYPE)-$(LIBC)-unknown
  else
    PKG_ARCH_PHT:=aarch64_generic-$(LIBC)-unknown
  endif
endif

ifeq ($(ARCH),mips)
    PKG_ARCH_PHT:=mips_24kc-$(LIBC)-unknown
endif

ifeq ($(ARCH),mipsel)
  ifneq ($(findstring $(CPU_TYPE), 24kec 74kc 1004kc),)
    PKG_ARCH_PHT:=$(ARCH)_$(CPU_TYPE)-$(LIBC)-unknown
  else
    PKG_ARCH_PHT:=mipsel_24kc-$(LIBC)-unknown
  endif
endif

ifeq ($(BOARD),x86)
  ifeq ($(ARCH),x86_64)
    PKG_ARCH_PHT:=x86_64-$(LIBC)-unknown
  else ifeq ($(CPU_TYPE),pentium4)
    PKG_ARCH_PHT:=i386_pentium4-$(LIBC)-unknown
  else
    PKG_ARCH_PHT:=i386_pentium-mmx-$(LIBC)-unknown
  endif
endif

# 源代码信息
PKG_SOURCE:=phtunnel
PKG_SOURCE_URL:=https://mirrors.oray.com/orayos/packages/$(PKG_NAME)/$(PKG_ARCH_PHT)/$(PKG_VERSION)/bin
PKG_HASH:=skip
PKG_FLAGS:=nonshared
PKG_MAINTAINER:=Oray <developer@oray.com>
PKG_LICENSE:=Proprietary

# 包含 APK 构建规则
include $(INCLUDE_DIR)/apk.mk

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
  PHTunnel is the core component of HSK intranet penetration, which can easily implement high-performance
  reverse proxy applications, supports TCP, HTTP, HTTPS protocols, end-to-end TLS encrypted communication,
  black and white list anti-black verification, etc. Through PHTunnel, external network devices can easily
  penetrate various complex routes and firewalls to access devices on the internal network.
endef

define Build/Prepare
    mkdir -p $(PKG_BUILD_DIR)
    mv $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)
    chmod +x $(PKG_BUILD_DIR)/$(PKG_SOURCE)
endef

define Build/Compile
    true
endef

# APK 安装目标
define Package/phtunnel/install
    $(INSTALL_DIR) $(APK_INSTALL_DIR)/etc/init.d
    $(INSTALL_DIR) $(APK_INSTALL_DIR)/etc/config
    $(INSTALL_DIR) $(APK_INSTALL_DIR)/etc/hotplug.d/iface
    $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/sbin

    $(INSTALL_BIN) $(PKG_BUILD_DIR)/phtunnel $(APK_INSTALL_DIR)/usr/sbin/
    $(INSTALL_BIN) ./files/etc/init.d/* $(APK_INSTALL_DIR)/etc/init.d/
    $(INSTALL_CONF) ./files/etc/config/* $(APK_INSTALL_DIR)/etc/config/
    $(INSTALL_BIN) ./files/etc/hotplug.d/iface/* $(APK_INSTALL_DIR)/etc/hotplug.d/iface/
endef

# APK 构建目标
define Build/APK
  # 生成 .PKGINFO 文件
  $(call Build/WritePKGINFO,$(APK_BUILD_DIR)/.PKGINFO)

  # 添加依赖
  echo "depend = libc" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = libpthread" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = librt" >> $(APK_BUILD_DIR)/.PKGINFO

  # 创建 .post-install 脚本
  cat > $(APK_BUILD_DIR)/.post-install << 'EOF'
#!/bin/sh
set -e

echo "PHTunnel 安装完成"

# 启用服务
if [ -f /etc/init.d/phtunnel ]; then
    /etc/init.d/phtunnel enable
    echo "PHTunnel 服务已启用"
fi

exit 0
EOF
  chmod +x $(APK_BUILD_DIR)/.post-install

  # 创建 .pre-install 脚本
  cat > $(APK_BUILD_DIR)/.pre-install << 'EOF'
#!/bin/sh
# 停止运行中的服务
if [ -f /etc/init.d/phtunnel ]; then
    /etc/init.d/phtunnel stop >/dev/null 2>&1 || true
fi
exit 0
EOF
  chmod +x $(APK_BUILD_DIR)/.pre-install

  # 打包
  $(TAR) -czf $(PKG_BUILD_DIR)/$(PKG_NAME)-$(APK_VERSION).apk \
    -C $(APK_BUILD_DIR) .
endef

$(eval $(call BuildPackage,phtunnel))
