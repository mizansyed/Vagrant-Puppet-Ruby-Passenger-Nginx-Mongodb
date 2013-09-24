# arnoudj/puppet-sudo

[![Build Status](https://travis-ci.org/arnoudj/puppet-sudo.png?branch=master)](https://travis-ci.org/arnoudj/puppet-sudo)

Allow restricted root access for specified users. The name of the defined
type must consist of only letters, numbers and underscores and should be
unique. If the name has incorrect characters the defined type will fail.
Sudoers entries realised with the `sudo::sudoers` defined type will be
stored in `"/etc/sudoers.d/[typename]"`.

This module expects that your OS/Distribution supports /etc/sudoers.d,
which is true for Ubuntu 10.04 and up and RedHat 6 and up. If this is not
the case for you, then you can overwrite the default sudoers file with
your own using the sudoers\_file parameter of the sudo class. And add the
line:

    #include /etc/sudoers.d

## Parameters for class sudo

### sudoers

Hash of sudoers entries, which will be created via sudo::sudoers.

### manage\_sudoersd

Boolean - should puppet clean /etc/sudoers.d/ of untracked files?

### sudoers\_file

Override the /etc/sudoers file with the file specified by this parameter.

## Parameters for type sudo::sudoers

### ensure

Controls the existence of the sudoers entry. Set this attribute to
present to ensure the sudoers entry exists. Set it to absent to
delete any computer records with this name Valid values are present,
absent.

### users

Array of users that are allowed to execute the command(s).

### cmnds

List of commands that the user can run.

### runas

The user that the command may be run as.

### cmnds

The commands which the user is allowed to run.

### tags

There are eight possible tag values, `NOPASSWD`, `PASSWD`, `NOEXEC`, `EXEC`,
`SETENV`, `NOSETENV`, `LOG_INPUT, NOLOG_INPUT`, `LOG_OUTPUT` and
`NOLOG_OUTPUT`.

## Example

A sudoers entry can be defined within a class or node definition:

    sudo::sudoers { 'worlddomination':
      ensure  => 'present',
      comment => 'World domination.',
      users   => ['pinky', 'brain'],
      runas   => ['root'],
      cmnds   => ['ALL'],
      tags    => ['NOPASSWD'],
    }

or via an ENC:

    ---
      classes:
        sudo:
          sudoers:
            worlddomination:
              ensure: present
              comment: "World Domination."
              users:
                - pinky
                - brain
              runas: 
                - root
              cmnds:
                - ALL
              tags:
                - NOPASSWD

## Contributors

* Justin Lambert
  * Added spec tests, travis integration and some code changes.
