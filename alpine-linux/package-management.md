# Package Managerment in Alpine Linux

Alpine uses [`apk` (Alpine Package Keeper)](https://docs.alpinelinux.org/user-handbook/0.1a/Working/apk.html) as its package manager.  `apk` would be the equivalent of `apt` on Ubuntu.

## Alpine Package Index

The Alpine package index is located at [https://pkgs.alpinelinux.org/packages](https://pkgs.alpinelinux.org/packages).

- The package index is especially useful when searching for a package by name
- The package index also indicates what versions of Alpine a package is available.  For example, the *dotnet-sdk* package is only available in v3.20 and later.

## Package Repositories

Alpine keeps the list of package repositories it will use in the file `/etc/apk/repositories`.  When you first install Alpine, the community repository in this file will be commented out.  You will need to uncomment this line to install most packages.

You want your `/etc/apk/repositories` to look like the following (though your version number may differ):

```output
#/media/cdrom/apks
http://dl-cdn.alpinelinux.org/alpine/v3.21/main
http://dl-cdn.alpinelinux.org/alpine/v3.21/community
```

## Common `apk` Commands

| **Command**                    | **Description**                    |
|--------------------------------|------------------------------------|
| `apk update`                   | Updates the package index metadata on your system by downloading new package metadata from the package repositories.  This only updates the package index metadata, not the packages themselves |
| `apk upgrade`                  | Upgrades all of the packages on the system.  This first updates the package metadata on your system, and then upgrades the packages themselves.  This means it is not technically necessary to first run `apk update` |
| `apk upgrade <package-name>` | Upgrade the package with the specified name.  |
| `apk add <package-name>`     | Add the package with the specified name to the system, for example `apk add nano`.  It is also possible to specify multiple package names such as `apk add nano curl git` |
| `apk del <package-name>`     | Remove the specified package from the system  |
| `apk search <package-name>`  | Search for the specified package              |
