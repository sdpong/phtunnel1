include $(TOPDIR)/rules.mk

# OpenWrt 25.12.x 包变量
PKG_NAME:=luci-app-phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

# LuCI 元数据
LUCI_TITLE:=LuCI Support for PHTunnel
LUCI_DEPENDS:=+cgi-io +curl +luci-lib-jsonc +phtunnel
LUCI_PKGARCH:=all

# 使用标准 luci.mk 和 package.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)
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

  define Package/phtunnel/description
   LuCI web interface for PHTunnel (HSK intranet penetration).

   This package provides a web interface for configuring and managing
   PHTunnel services in OpenWrt 25.12.x.
 endef
 
 define Build/Prepare
   mkdir -p $(PKG_BUILD_DIR)
   
   # 复制LuCI源文件
   if [ -d ./luasrc ]; then
     cp -r ./luasrc/* $(PKG_BUILD_DIR)/
   fi
   
   # 复制根文件系统文件
   if [ -d ./root ]; then
     cp -r ./root/* $(PKG_BUILD_DIR)/
   fi
   
   # 复制国际化文件
   if [ -d ./po ]; then
     cp -r ./po $(PKG_BUILD_DIR)/
   fi
 endef
 
 define Build/Compile
   # LuCI应用无需编译，文件已经准备好
   true
 endef
 
 define Package/$(PKG_NAME)/install
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/oray
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/oray
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/oray
  $(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
  $(INSTALL_DIR) $(1)/usr/share/luci/menu.d
  $(INSTALL_DIR) $(1)/usr/share/luci/i18n

  # LuCI 模块文件
  if [ -d $(PKG_BUILD_DIR)/luasrc ]; then
    $(CP) $(PKG_BUILD_DIR)/luasrc/* $(1)/usr/lib/lua/luci/
  fi

  # RPC ACL 配置
  if [ -d $(PKG_BUILD_DIR)/root ]; then
    $(CP) $(PKG_BUILD_DIR)/root/* $(1)/
  fi
 
   # 国际化文件
  if [ -d $(PKG_BUILD_DIR)/po ]; then \
    $(foreach lang,$(filter-out templates,$(notdir $(wildcard $(PKG_BUILD_DIR)/po/*))), \
      $(INSTALL_DATA) $(PKG_BUILD_DIR)/po/$(lang)/$(PKG_NAME).po $(1)/usr/share/luci/i18n/$(PKG_NAME).$(lang).po; \
   fi \
endef
