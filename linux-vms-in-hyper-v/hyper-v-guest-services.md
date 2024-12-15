# Hyper-V Guest Services

[Hyper-V Integration Services](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/reference/integration-services) (sometimes called Guest services) allow a virtual machine to exchange information with the Hyper-V host.  This allows better integration between the VM and the host server.

These services are available for both Windows and Linux operating systems, though functionality can vary somewhat between different distributions.

## Alpine Linux

This inforamtion comes from the article [Hyper-V guest services](https://wiki.alpinelinux.org/wiki/Hyper-V_guest_services) on the official Alpine Linux website.

First, install the Hyper-V guest services package:

```bash
apk add hvtools
```

Then enable the services:

```bash
rc-service hv_fcopy_daemon start
rc-service hv_kvp_daemon start
rc-service hv_vss_daemon start
```

Finally, configure the services to start at boot:

```bash
rc-update add hv_fcopy_daemon
rc-update add hv_kvp_daemon
rc-update add hv_vss_daemon
```
