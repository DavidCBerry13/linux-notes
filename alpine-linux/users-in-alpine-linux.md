# Managing Users in Alpine Linux

Alpine Linux uses the typical Linux users and groups.  This page documents some commands used to manipulate users and groups in common scenarios for quick reference.

## Shells

Alpine does not install popular shells like `bash` or `zsh` by default.  If you want a user to use these shell's, you need to install them using [Alpine's package manager](package-management.md).

```bash
apk add bash zsh
```

## Group Managerment

Groups are stored in the `/etc/group` file in Linux.

Users can belong to multiple groups.  A user will have a group specified in the `/etc/passwd` file and can be a member of additional groups in the `/etc/group` file.

Groups can be created using the `addgroup` command as follows:

```bash
addgroup web-users
```

You can also use the `addgroup` command to add one or more users to a group

```bash
addgroup web-users alice bob charlie
```

## User Management

Users are stored in the `/etc/passwd` file on Linux systems.  

To add a new user on Alpine, use the [adduser](https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user) command.

### Creating a Normal User

The following command will create a login user *jcaesar* for the person named *Julius Caesar* using the `/bin/bash` shell.

```bash
adduser -g "Julius Caesar" -G users -s /bin/bash jcaesar
```

The options are as follows:

- `-g` - Used to specify the user's full name.
- `-G` - Specifies this user will be added to the *users* group
- `-s` - Used to specify the shell for the user.  Defaults to /bin/ash.
- The username is specified as the last parameter (*jcaesar* in this case)

You will be prompted for a password and to confirm the password after running the above command.

On Alpine, if you do not specify a group for the user, a new group named after the user will be created.  For some scenarios this may be fine, but for others, this may be undesirable and you will want to be sure to specify an existing group.

### Creating a Service User

Often times, you need to create a user to run a service, for example to run a *nginx* web server because you don't want these services to run as root. In these cases, it is possible to create users without a password that Alpine will only allow to run services but not login.

```bash
adduser -S -D -g 'NGINX www user' -G www www
```

- `-S` - Creates a system user (a user with a UID < 1000).  Not technicially required, more of a convention to differentiate system users from regular users
- `-D` - Disabled password, so teh user is not allowed to login
- `-g` - Provides the full name of this service user.  Not required, but useful to know what this account is for
- `-G` - Specifies this users belongs to the *www* group
- The username is specified as the last parameter (*www* in this case)
