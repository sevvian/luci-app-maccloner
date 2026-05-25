include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-maccloner
PKG_VERSION:=1.0.6
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=MAC Cloner for Wi-Fi Interfaces
  DEPENDS:=+luci-base +libiwinfo
  PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
  Automatically applies a custom MAC address when a Wi-Fi client connects to a specific SSID.
  Uses wpa_cli events for reliable per-interface triggering.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	# LuCI Lua source files
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/maccloner.lua $(1)/usr/lib/lua/luci/controller/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/maccloner.lua $(1)/usr/lib/lua/luci/model/cbi/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/maccloner
	$(INSTALL_DATA) ./luasrc/view/maccloner/status.htm $(1)/usr/lib/lua/luci/view/maccloner/

	# UCI default configuration
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/maccloner $(1)/etc/config/

	# Hotplug script (first line of defence)
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./root/etc/hotplug.d/iface/99-maccloner $(1)/etc/hotplug.d/iface/

	# wpa_cli action script (per-interface trigger)
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) ./root/etc/wpa_action.sh $(1)/etc/

	# procd init script for wpa_cli daemon
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/maccloner $(1)/etc/init.d/
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
    # Restore default config if missing
    [ -f /etc/config/maccloner ] || cp /rom/etc/config/maccloner /etc/config/

    # Ensure hotplug script is executable
    [ -x /etc/hotplug.d/iface/99-maccloner ] && chmod 755 /etc/hotplug.d/iface/99-maccloner

    # Enable and start the wpa_cli event service
    /etc/init.d/maccloner enable
    /etc/init.d/maccloner start
fi
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
    # Stop and disable the service before removal
    /etc/init.d/maccloner stop 2>/dev/null
    /etc/init.d/maccloner disable 2>/dev/null
    rm -f /etc/hotplug.d/iface/99-maccloner
fi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
