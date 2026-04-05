include $(TOPDIR)/rules.mk

# APK 特定变量
PKG_NAME:=luci-app-phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=r1  # 关键修改：1 → r1

# APK 包名和版本
APK_NAME:=$(PKG_NAME)
APK_VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
APK_ARCH:=all  # LuCI 应用通常是 all 架构

# LuCI 元数据（保持不变）
LUCI_TITLE:=LuCI Support for the PHTunnel
# 依赖需要调整语法
LUCI_DEPENDS:=+cgi-io +curl +luci-compat +luci-lib-json +phtunnel

# 关键修改：包含 apk.mk 替代默认的 package.mk
include $(INCLUDE_DIR)/apk.mk

# 包含 LuCI 构建规则
include $(TOPDIR)/feeds/luci/luci.mk

# APK 包定义
define Package/$(PKG_NAME)
  # LuCI 标准字段
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=$(LUCI_TITLE)
  URL:=https://github.com/oooopera/phtunnel1
  
  # APK 额外元数据字段
  MAINTAINER:=Oray <developer@oray.com>
  LICENSE:=GPL-2.0-only
  ARCH:=all
  
  # 提供虚拟包信息
  PROVIDES:=luci-app-phtunnel luci-i18n-phtunnel-zh-cn
endef

define Package/$(PKG_NAME)/description
  LuCI web interface for PHTunnel (HSK intranet penetration).
  
  This package provides a web interface for configuring and managing
  PHTunnel services in OpenWrt 25 with APK support.
endef

# APK 构建目标
define Build/APK
  # 生成 .PKGINFO 文件
  $(call Build/WritePKGINFO,$(APK_BUILD_DIR)/.PKGINFO)
  
  # 添加 APK 特定依赖
  echo "# LuCI dependencies" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = cgi-io" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = curl" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = luci-compat" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = luci-lib-json" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "depend = phtunnel" >> $(APK_BUILD_DIR)/.PKGINFO
  
  # 添加提供信息
  echo "provides = luci-app-phtunnel" >> $(APK_BUILD_DIR)/.PKGINFO
  echo "provides = luci-i18n-phtunnel-zh-cn" >> $(APK_BUILD_DIR)/.PKGINFO
  
  # 创建 .post-install 脚本处理 LuCI 兼容性
  cat > $(APK_BUILD_DIR)/.post-install << 'EOF'
#!/bin/sh
set -e

echo "LuCI PHTunnel 界面安装完成"

# 检查 LuCI 兼容性
if [ ! -d /usr/lib/lua/luci ]; then
    echo "警告: LuCI 核心未安装，界面可能无法正常工作"
    echo "请安装: apk add luci"
fi

# 检查 phtunnel 依赖
if ! command -v phtunnel >/dev/null 2>&1; then
    echo "警告: phtunnel 核心程序未安装"
    echo "请安装: apk add phtunnel"
fi

exit 0
EOF
  chmod +x $(APK_BUILD_DIR)/.post-install
  
  # 打包
  $(TAR) -czf $(PKG_BUILD_DIR)/$(APK_NAME)-$(APK_VERSION).apk \
    -C $(APK_BUILD_DIR) .
endef

# 安装目录调整
define Package/$(PKG_NAME)/install
  # 使用 APK_INSTALL_DIR 替代默认的安装目录
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/lib/lua/luci
  $(INSTALL_DIR) $(APK_INSTALL_DIR)/www/luci-static/resources
  
  # LuCI 模块文件
  if [ -d $(PKG_BUILD_DIR)/luasrc ]; then
    $(CP) $(PKG_BUILD_DIR)/luasrc/* $(APK_INSTALL_DIR)/usr/lib/lua/luci/
  endif
  
  # 静态资源
  if [ -d $(PKG_BUILD_DIR)/htdocs ]; then
    $(CP) $(PKG_BUILD_DIR)/htdocs/* $(APK_INSTALL_DIR)/www/luci-static/resources/
  endif
  
  # LuCI 菜单配置（如果存在）
  if [ -f $(PKG_BUILD_DIR)/luci-app-phtunnel.json ]; then
    $(INSTALL_DIR) $(APK_INSTALL_DIR)/usr/share/luci/menu.d
    $(INSTALL_DATA) $(PKG_BUILD_DIR)/luci-app-phtunnel.json \
      $(APK_INSTALL_DIR)/usr/share/luci/menu.d/
  endif
endef

# OpenWrt 25 LuCI 兼容性处理
define Package/$(PKG_NAME)/postinst
  #!/bin/sh
  [ -n "" ] || exit 0
  
  # 清理 LuCI 缓存
  rm -rf /tmp/luci-*
  /etc/init.d/rpcd restart >/dev/null 2>&1 || true
  /etc/init.d/uhttpd restart >/dev/null 2>&1 || true

  echo "LuCI PHTunnel 界面已安装，请刷新浏览器页面"
  exit 0
endef

# 兼容性：同时支持 IPK 和 APK 的调用
$(eval $(call BuildPackage,$(PKG_NAME)))
