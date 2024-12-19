# Package Managerment in Ubunt

Ubuntu uses [`apt`](https://documentation.ubuntu.com/server/how-to/software/package-management/) as its package manager.

## Package Index

The package sources are stored in teh file `/etc/apt/sources.list` file and `/etc/apt/sources.list.d` directory.  To add additional package repositories, you would [edit these files](https://documentation.ubuntu.com/server/how-to/software/package-management/#extra-repositories).

To update the package indexes, use the `apt update` command:

```bash
sudo apt update
```

## Installing a Package

To install a package, use `apt install` and the package name(s)

```bash
sudo apt install vim
```

## Listing packages on a System

Use the `apt list` command

```bash
sudo apt list
```

## Removing a Package

To remove a package, use the `apt remove` command with the package name(s).

```bash
sudo apt remove vim
```

## Upgrading Packages

First, be sure to update your package indexes using the `apt update` command

```bash
sudo apt update
```

Then, run `apt list --upgradable` to see what packages can be updated

```bash
sudo apt list --upgradable
```

Then, you can upgrade a single package at a time using `apt upgrade`

```bash
sudo apt upgrade vim
```

You can also upgrade all of the packages that need upgraded at once

```bash
sudo apt upgrade
```