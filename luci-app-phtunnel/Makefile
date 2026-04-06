include $(TOPDIR)/rules.mk

# OpenWrt 25 标准 IPK 包变量
PKG_NAME:=luci-app-phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

# LuCI 元数据
LUCI_TITLE:=LuCI Support for PHTunnel
# 向下兼容：OpenWrt 25 使用 luci-lib-jsonc，低版本使用 luci-lib-json
LUCI_DEPENDS:=+cgi-io +curl +luci-lib-json +luci-lib-jsonc +phtunnel
LUCI_PKGARCH:=all

# 包含标准构建规则
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/luci/luci.mk

# LuCI 包定义
define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=$(LUCI_TITLE)
  URL:=https://github.com/oooopera/phtunnel1
  MAINTAINER:=Oray <developer@oray.com>
  LICENSE:=GPL-2.0-only
  DEPENDS:=$(LUCI_DEPENDS)
endef

define Package/$(PKG_NAME)/description
  LuCI web interface for PHTunnel (HSK intranet penetration).

  This package provides a web interface for configuring and managing
  PHTunnel services.

  Compatibility:
  - OpenWrt 25.12.x (recommended)
  - OpenWrt 24.x
  - OpenWrt 23.x
  - OpenWrt 22.x
  - OpenWrt 21.02 and above
endef

# OpenWrt 25 安装目标
define Package/$(PKG_NAME)/install
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/oray
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/model
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/oray
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/oray
  $(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
  $(INSTALL_DIR) $(1)/usr/share/luci/menu.d

  # LuCI 模块文件
  if [ -d $(PKG_BUILD_DIR)/luasrc ]; then
    $(CP) $(PKG_BUILD_DIR)/luasrc/* $(1)/usr/lib/lua/luci/
  endif

  # RPC ACL 配置
  if [ -d $(PKG_BUILD_DIR)/root ]; then
    $(CP) $(PKG_BUILD_DIR)/root/* $(1)/
  endif

  # 国际化文件
  $(INSTALL_DIR) $(1)/usr/share/luci/i18n
  if [ -d $(PKG_BUILD_DIR)/po ]; then
    $(foreach lang,$(filter-out templates,$(notdir $(wildcard $(PKG_BUILD_DIR)/po/*))), \
      $(INSTALL_DATA) $(PKG_BUILD_DIR)/po/$(lang)/$(PKG_NAME).po $(1)/usr/share/luci/i18n/$(PKG_NAME).$(lang).po;)
  endif
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
