include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-maccloner
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

LUCI_TITLE:=LuCI Support for MAC Cloner
LUCI_DEPENDS:=+luci-base +libiwinfo
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
    [ -f /etc/config/maccloner ] || cp /rom/etc/config/maccloner /etc/config/
    [ -x /etc/hotplug.d/iface/99-maccloner ] && chmod 755 /etc/hotplug.d/iface/99-maccloner
fi
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
    /etc/init.d/maccloner disable 2>/dev/null
    rm -f /etc/hotplug.d/iface/99-maccloner
fi
endef

# call BuildPackage - OpenWrt buildroot signature
$(eval $(call BuildPackage,$(PKG_NAME)))
