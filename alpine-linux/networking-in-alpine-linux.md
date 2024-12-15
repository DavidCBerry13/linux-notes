# Alpine Linux Networking

By default, Alpine will be configured to use DHCP.  However, it is possible to set one or more static IP addresses for an Alpine server

Network interfaces are configured in the file `/etc/network/interfaces` in Alpine.  `eth0` is the default network interface (`lo` is the loopback interface).

The default `/etc/network/interfaces` file looks like this:

```output
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## Setting a Static IP Address

To set a static IP address, modify the `eth0` configuration block to look like this:

```output
auto eth0
iface eth0 inet static
        address 10.1.2.101/24
        gateway 10.1.2.1
        hostname alpine-server
```

In this case:

- The IP address is set to `10.1.2.101`
- The subnet mask is set to `255.255.255.0` using CIDR notation (`/24`)
- The gateway is set to `10.1.2.1`
- The hostname is set to `alpine-server`

For these changes to take effect, you need to restart the networking service

```bash
service networking restart
```
