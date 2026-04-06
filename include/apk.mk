# OpenWrt 25.12.x APK 构建系统支持
# 基于 Alpine Linux APK 格式

# APK 构建目录
APK_BUILD_DIR ?= $(PKG_BUILD_DIR)/apk-build
APK_INSTALL_DIR ?= $(PKG_BUILD_DIR)/apk-install

# APK 版本信息
APK_VERSION_FORMAT = $(PKG_VERSION)-$(PKG_RELEASE)
APK_ARCH ?= $(subst $(PKG_BUILD_DIR)/,,$(dir $(PKG_BUILD_DIR)))
APK_ARCH := $(if $(APK_ARCH),$(APK_ARCH),all)

# 构建/WritePKGINFO 辅助函数
define Build/WritePKGINFO
	$(INSTALL_DIR) $(1)
	echo "pkgname = $(PKG_NAME)" > $(1)/.PKGINFO
	echo "pkgver = $(APK_VERSION_FORMAT)" >> $(1)/.PKGINFO
	echo "pkgdesc = $(subst $(newline),\n,$(Package/$(PKG_NAME)/description))" >> $(1)/.PKGINFO
	echo "url = $(URL)" >> $(1)/.PKGINFO
	echo "builddate = $(shell date -u +%Y%m%d%H%M%S)" >> $(1)/.PKGINFO
	echo "packager = OpenWrt Build System" >> $(1)/.PKGINFO
	echo "size = $(shell du -sb $(APK_INSTALL_DIR))" >> $(1)/.PKGINFO
	echo "arch = $(APK_ARCH)" >> $(1)/.PKGINFO
	echo "license = $(LICENSE)" >> $(1)/.PKGINFO
	echo "maintainer = $(MAINTAINER)" >> $(1)/.PKGINFO
	echo "origin = openwrt" >> $(1)/.PKGINFO
endef
