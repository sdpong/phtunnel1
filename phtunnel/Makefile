include $(TOPDIR)/rules.mk

# OpenWrt 25.12.x APK 包变量
PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

# APK 包名和版本
APK_NAME:=$(PKG_NAME)
APK_VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
APK_ARCH:=$(ARCH)

# 源代码信息
PKG_SOURCE:=phtunnel
PKG_SOURCE_URL:=https://mirrors.oray.com/orayos/packages/$(PKG_NAME)/$(PKG_VERSION)/bin
PKG_HASH:=skip
PKG_FLAGS:=nonshared
PKG_MAINTAINER:=Oray <developer@oray.com>
PKG_LICENSE:=Proprietary

# APK 元数据
APK_DESCRIPTION:=PHTunnel core daemon for OpenWrt 25.12.x+
APK_URL:=https://hsk.oray.com/
APK_LICENSE:=Proprietary
APK_MAINTAINER:=Oray <developer@oray.com>
APK_ORIGIN:=openwrt

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
    $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)
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
  $(call Build/WritePKGINFO,$(APK_BUILD_DIR)/.PKGINFO)

  # 添加依赖
  echo "depend = libc" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = libpthread" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = librt" >> $(APK_BUILD_DIR)/.PKGINFO

  # 创建 .post-install 脚本
  echo '#!/bin/sh' > $(APK_BUILD_DIR)/.post-install
  echo 'set -e' >> $(APK_BUILD_DIR)/.post-install
  echo '' >> $(APK_BUILD_DIR)/.post-install
  echo 'echo "PHTunnel 安装完成"' >> $(APK_BUILD_DIR)/.post-install
  echo '' >> $(APK_BUILD_DIR)/.post-install
  echo '# 启用服务' >> $(APK_BUILD_DIR)/.post-install
  echo 'if [ -f /etc/init.d/phtunnel ]; then' >> $(APK_BUILD_DIR)/.post-install
  echo '    /etc/init.d/phtunnel enable' >> $(APK_BUILD_DIR)/.post-install
  echo '    echo "PHTunnel 服务已启用"' >> $(APK_BUILD_DIR)/.post-install
  echo 'fi' >> $(APK_BUILD_DIR)/.post-install
  echo '' >> $(APK_BUILD_DIR)/.post-install
  echo 'exit 0' >> $(APK_BUILD_DIR)/.post-install
  chmod +x $(APK_BUILD_DIR)/.post-install

  # 创建 .pre-install 脚本
  echo '#!/bin/sh' > $(APK_BUILD_DIR)/.pre-install
  echo '# 停止运行中的服务' >> $(APK_BUILD_DIR)/.pre-install
  echo 'if [ -f /etc/init.d/phtunnel ]; then' >> $(APK_BUILD_DIR)/.pre-install
  echo '    /etc/init.d/phtunnel stop >/dev/null 2>&1 || true' >> $(APK_BUILD_DIR)/.pre-install
  echo 'fi' >> $(APK_BUILD_DIR)/.pre-install
  echo 'exit 0' >> $(APK_BUILD_DIR)/.pre-install
  chmod +x $(APK_BUILD_DIR)/.pre-install

  # 创建 APK 包
  mkdir -p $(APK_INSTALL_DIR)
  $(call Package/phtunnel/install,$(APK_INSTALL_DIR))

  $(TAR) -czf $(PKG_BUILD_DIR)/$(APK_NAME)-$(APK_VERSION)_$(APK_ARCH).apk \
    -C $(APK_BUILD_DIR) .PKGINFO .pre-install .post-install \
    -C $(APK_INSTALL_DIR) .
endef

$(eval $(call BuildPackage,phtunnel))
