# Build Intel Edison RootFS Image

Yocto layer: https://github.com/edison-fw/meta-intel-edison/

## Login

Login via serial port. default user is `root` with no password.

## WiFi

Configuration

``` shell
cat << 'EOF' | tee /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1

network={
  ssid="<SSID>"
  psk="<password>"
  key_mgmt=WPA-PSK
  proto=WPA2
  pairwise=CCMP TKIP
  group=CCMP TKIP
  scan_ssid=1
}
EOF
```

``` shell
cat << 'EOF' | tee /etc/systemd/network/25-wlan.network
[Match]
Name=wlan0

[Network]
DHCP=yes
EOF
```

Connect to WiFi

``` shell
systemctl enable --now wpa_supplicant@wlan0.service
systemctl enable --now systemd-networkd.service
```
