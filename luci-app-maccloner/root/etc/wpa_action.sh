#!/bin/sh
# Called by wpa_cli: $1 = event (e.g. CONNECTED), $2 = interface name

[ "$1" = "CONNECTED" ] || exit 0
IFACE="$2"

. /lib/functions/network.sh
logger -t maccloner-wpa "wpa_cli event: $1 on $IFACE"

# Check global enable
[ "$(uci -q get maccloner.settings.enabled)" = "1" ] || exit 0

# Loop through rules using numeric indexing (no grep -P)
idx=0
while true; do
    rule_section="maccloner.@rule[${idx}]"
    uci -q get ${rule_section}.interface >/dev/null || break
    idx=$((idx + 1))

    [ "$(uci -q get ${rule_section}.enabled)" = "1" ] || continue

    RULE_IFACE=$(uci -q get ${rule_section}.interface)
    [ "$RULE_IFACE" = "$IFACE" ] || continue

    TARGET_SSID=$(uci -q get ${rule_section}.target_ssid)
    CUSTOM_MAC=$(uci -q get ${rule_section}.custom_mac)
    [ -z "$CUSTOM_MAC" ] && continue

    # Get current SSID
    CURRENT_SSID=$(iwinfo "$IFACE" info | sed -n 's/.*SSID: "\(.*\)"/\1/p')
    if [ -n "$TARGET_SSID" ] && [ "$CURRENT_SSID" != "$TARGET_SSID" ]; then
        logger -t maccloner-wpa "SSID mismatch ($CURRENT_SSID), skipping."
        continue
    fi

    # Skip if MAC already correct
    CURRENT_MAC=$(cat /sys/class/net/$IFACE/address 2>/dev/null | tr '[:upper:]' '[:lower:]')
    if [ "$CURRENT_MAC" = "$(echo $CUSTOM_MAC | tr '[:upper:]' '[:lower:]')" ]; then
        exit 0
    fi

    # Find radio
    PHY=""
    [ -x /usr/sbin/iw ] && PHY=$(iw dev "$IFACE" info 2>/dev/null | grep wiphy | awk '{print $2}')
    [ -z "$PHY" ] && PHY=$(cat /sys/class/net/$IFACE/phy80211/name 2>/dev/null)
    RADIO="radio${PHY#phy}"

    logger -t maccloner-wpa "Applying MAC $CUSTOM_MAC to $IFACE (radio $RADIO, SSID $CURRENT_SSID)"

    # Locate the correct wifi-iface section
    FOUND=0
    widx=0
    while true; do
        wifi_section="wireless.@wifi-iface[${widx}]"
        uci -q get ${wifi_section}.device >/dev/null || break
        widx=$((widx + 1))

        [ "$(uci -q get ${wifi_section}.device)" = "$RADIO" ] || continue
        [ "$(uci -q get ${wifi_section}.mode)" = "sta" ] || continue
        [ "$(uci -q get ${wifi_section}.ssid)" = "$CURRENT_SSID" ] || continue

        uci set ${wifi_section}.macaddr="$CUSTOM_MAC"
        uci commit wireless
        wifi reload
        logger -t maccloner-wpa "Wireless restarted for $IFACE."
        FOUND=1
        break
    done
    [ "$FOUND" -eq 0 ] && logger -t maccloner-wpa "Could not find wifi-iface for $IFACE."
    exit 0
done
