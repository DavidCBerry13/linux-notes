# Services in Alpine Linux

Alpine uses [OpenRC ](https://wiki.gentoo.org/wiki/OpenRC) as its init system.  OpenRC performs the same function as [systemd](https://en.wikipedia.org/wiki/Systemd) performns in many other Linux distributions in terms of starting up and managing services on the system.

The OpenRC scripts that start different services on an Alpine Linux system are located in the `/etc/init.d` directory.

## Service Management

| **Command**                          | **Description**                                     |
|--------------------------------------|-----------------------------------------------------|
| `rc-service --list`                  | Lists all the services                              |
| `rc-service status <service-name>`   | Gets the status of the specified service            |
| `rc-service <service-name> start`    | Start the specified service                         |
| `rc-service <service-name> restart`  | Restarts the specified service                      |
| `rc-service <service-name> start`    | Stops the specified service                         |
| `rc-update add <service-name>`       | Adds the specified service to start on boot         |
| `rc-update delete <service-name>`    | Removes the specified service from starting on boot |

You can also control services with teh `service` command

| **Command**                      | **Description**                             |
|----------------------------------|---------------------------------------------|
| `service <service-name> start`   | Start the specified service                 |
| `service <service-name> restart` | Restarts the specified service              |
| `service <service-name> start`   | Stops the specified service                 |

## References

- [rc-status](https://manpages.org/rc-status/8) man page
- [rc-service](https://manpages.org/rc-service/8) man page
- [rc-update](https://manpages.org/rc-update/8) man page
