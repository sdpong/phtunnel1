include $(TOPDIR)/rules.mk

# OpenWrt 25.12.x APK 包变量
PKG_NAME:=luci-app-phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=2

# APK 包名和版本
APK_NAME:=$(PKG_NAME)
APK_VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
APK_ARCH:=all

# LuCI 元数据
LUCI_TITLE:=LuCI Support for PHTunnel
LUCI_DEPENDS:=+cgi-io +curl +luci-lib-jsonc +phtunnel
LUCI_PKGARCH:=all

# 包含 APK 构建规则
include $(INCLUDE_DIR)/apk.mk
include $(TOPDIR)/feeds/luci/luci.mk

# APK 包定义
define Package/$(PKG_NAME)
  # LuCI 标准字段
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=$(LUCI_TITLE)
  URL:=https://github.com/oooopera/phtunnel1
  MAINTAINER:=Oray <developer@oray.com>
  LICENSE:=GPL-2.0-only
  DEPENDS:=$(LUCI_DEPENDS)
  ARCH:=all
endef

define Package/$(PKG_NAME)/description
  LuCI web interface for PHTunnel (HSK intranet penetration).

  This package provides a web interface for configuring and managing
  PHTunnel services in OpenWrt 25.12.x.
endef

# APK 构建目标
define Build/APK
  # 生成 .PKGINFO 文件
  $(call Build/WritePKGINFO,$(APK_BUILD_DIR)/.PKGINFO)

  # 添加 APK 特定依赖
  echo "# LuCI dependencies" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = cgi-io" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = curl" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = luci-lib-jsonc" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = phtunnel" >> $(APK_BUILD_DIR)/.PKGINFO

  # 创建 .post-install 脚本处理 LuCI 兼容性
  cat > $(APK_BUILD_DIR)/.post-install << 'EOF'
#!/bin/sh
set -e

echo "LuCI PHTunnel 界面安装完成"

# 清理 LuCI 缓存
rm -rf /tmp/luci-* >/dev/null 2>&1 || true

# 重启 rpcd 服务
/etc/init.d/rpcd restart >/dev/null 2>&1 || true

# 重启 uhttpd 服务
/etc/init.d/uhttpd restart >/dev/null 2>&1 || true

exit 0
EOF
  chmod +x $(APK_BUILD_DIR)/.post-install

  # 打包
  $(TAR) -czf $(PKG_BUILD_DIR)/$(APK_NAME)-$(APK_VERSION).apk \
    -C $(APK_BUILD_DIR) .
endef

# APK 安装目标
define Package/$(PKG_NAME)/install
  # 使用 APK_INSTALL_DIR（由 apk.mk 定义）
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/lib/lua/luci
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/lib/lua/luci/controller
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/lib/lua/luci/controller/oray
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/lib/lua/luci/model
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/lib/lua/luci/model/cbi
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/lib/lua/luci/model/cbi/oray
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/lib/lua/luci/view
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/lib/lua/luci/view/oray
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/share/rpcd/acl.d
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/share/luci/menu.d

  # LuCI 模块文件
  if [ -d $(PKG_BUILD_DIR)/luasrc ]; then
    $(CP) $(PKG_BUILD_DIR)/luasrc/* $(APK_INSTALL_DIR)/usr/lib/lua/luci/
  fi

  # RPC ACL 配置
  if [ -d $(PKG_BUILD_DIR)/root ]; then
    $(CP) $(PKG_BUILD_DIR)/root/* $(APK_INSTALL_DIR)/
  fi

  # 国际化文件
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/share/luci/i18n
  if [ -d $(PKG_BUILD_DIR)/po ]; then
    $(foreach lang,$(filter-out templates,$(notdir $(wildcard $(PKG_BUILD_DIR)/po/*))), \
      $(INSTALL_DATA) $(PKG_BUILD_DIR)/po/$(lang)/$(PKG_NAME).po $(APK_INSTALL_DIR)/usr/share/luci/i18n/$(PKG_NAME).$(lang).po;)
  endif
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
