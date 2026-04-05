include $(TOPDIR)/rules.mk

# APK 特定变量
PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=r1  # 关键修改：1 → r1

# APK 包名和版本
APK_NAME:=$(PKG_NAME)
APK_VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)

include $(INCLUDE_DIR)/target.mk

# 架构检测逻辑保持不变，但需要适应 APK 架构命名
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

# 设置 APK 架构变量
APK_ARCH:=$(PKG_ARCH_PHT)

# 源代码信息保持不变
PKG_SOURCE:=phtunnel
PKG_SOURCE_URL:=https://mirrors.oray.com/orayos/packages/$(PKG_NAME)/$(PKG_ARCH_PHT)/$(PKG_VERSION)/bin
PKG_HASH:=skip
PKG_FLAGS:=nonshared
PKG_MAINTAINER:=Oray <developer@oray.com>

# 关键修改：包含 apk.mk 替代 package.mk
include $(INCLUDE_DIR)/apk.mk

define Package/phtunnel
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  # 依赖语法需要调整
  DEPENDS:=@(arm||aarch64||mips||mipsel||i386||x86_64) \
    +libc +libpthread +librt
  TITLE:=HSK Intranet penetration
  URL:=https://hsk.oray.com/
  # APK 额外元数据字段
  MAINTAINER:=Oray <developer@oray.com>
  LICENSE:=Proprietary
  # 提供虚拟包信息
  PROVIDES:=phtunnel
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

# APK 没有 conffiles，需要调整配置处理方式
# define Package/phtunnel/conffiles
# /etc/phtunnel.json
# endef

define Package/phtunnel/install
    # 使用 APK_INSTALL_DIR 替代 $(1)
    $(INSTALL_DIR) $(APK_INSTALL_DIR)/etc/init.d
    $(INSTALL_DIR) $(APK_INSTALL_DIR)/etc/config
    $(INSTALL_DIR) $(APK_INSTALL_DIR)/etc/hotplug.d/iface
    $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/sbin
    
    $(CP) $(PKG_BUILD_DIR)/phtunnel $(APK_INSTALL_DIR)/usr/sbin
    $(INSTALL_BIN) ./files/etc/init.d/* $(APK_INSTALL_DIR)/etc/init.d
    $(INSTALL_CONF) ./files/etc/config/* $(APK_INSTALL_DIR)/etc/config
    $(INSTALL_BIN) ./files/etc/hotplug.d/iface/* $(APK_INSTALL_DIR)/etc/hotplug.d/iface
    
    # 配置文件特殊处理：使用 .apk-new 后缀
    ifdef Package/phtunnel/conffiles
        $(foreach conf,$(shell cat ./files/conffiles 2>/dev/null || echo), \
            $(if $(wildcard $(APK_INSTALL_DIR)/$(conf)), \
                mv $(APK_INSTALL_DIR)/$(conf) $(APK_INSTALL_DIR)/$(conf).apk-new, \
            ) \
        )
    endif
endef

# 安装脚本需要重命名和调整
# IPK: preinst → APK: .pre-install
define Package/phtunnel/preinstall
#!/bin/sh
[ -z "" ] && {
    pidof phtunnel > /dev/null && \
        test -f /etc/init.d/phtunnel && \
            /etc/init.d/phtunnel stop; true
}
exit 0
endef

# APK 构建目标
define Build/APK
    # 生成 .PKGINFO 文件
    $(call Build/WritePKGINFO,$(APK_BUILD_DIR)/.PKGINFO)
    
    # 处理安装脚本
    ifdef Package/$(PKG_NAME)/preinstall
        $(INSTALL_BIN) $(PKG_BUILD_DIR)/preinstall $(APK_BUILD_DIR)/.pre-install
    endif
    
    # 创建 .post-install 脚本处理配置文件
    cat > $(APK_BUILD_DIR)/.post-install << 'EOF'
#!/bin/sh
set -e

# 配置文件保护
if [ ! -f /etc/phtunnel.json ]; then
    if [ -f /etc/phtunnel.json.apk-new ]; then
        cp /etc/phtunnel.json.apk-new /etc/phtunnel.json
        echo "已创建默认配置文件: /etc/phtunnel.json"
    fi
fi

# 启用服务
if [ -f /etc/init.d/phtunnel ]; then
    /etc/init.d/phtunnel enable
    echo "PHTunnel 服务已启用"
fi

exit 0
EOF
    chmod +x $(APK_BUILD_DIR)/.post-install
    
    # 打包
    $(TAR) -czf $(PKG_BUILD_DIR)/$(APK_NAME)-$(APK_VERSION).apk \
        -C $(APK_BUILD_DIR) .
endef

$(eval $(call BuildPackage,phtunnel))
