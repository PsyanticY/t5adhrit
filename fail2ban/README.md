# Fail2ban

Todo: Check datepattern

### This was during configuring fail2ban to keep a FreeIPA server safe:

Install it using `yum` or `apt-get` or `nix-env`

Need to set up firewalld/iptables to allow all traffic and only bans non needed IP addresses who want to brute force things

Let's discuss firewalld in our case:
* we need to install firewalld and set the zone to trusted named `freeipa` is this case
* Only deny access to given IPs using firewalld's rich rules:
`firewall-cmd  --zone=freeipa --add-rich-rule='rule family="ipv4" source address="172.16.119.1" port protocol="tcp" port="22" reject'`

__Note__: This is not permanent as it is not permanent banned in fail2ban anyway


- Change firewalld interface: `firewall-cmd --zone=public --change-interface=eth0`
- Change zone default behaviour: `firewall-cmd --zone=public --set-target=ACCEPT --permanent`

--------------------------------------------------------------------------------

### Fail2ban config files:
jail.local
```
[DEFAULT]
# Ban hosts for two hours:
bantime = 7200
findtime = 300
maxretry = 2
banaction = firewallcmd-rich-rules
ignoreip = 127.0.0.1/8, 10.100.46.0/24 # ...

[freeipa]
enabled = true
port    = ldaps
filter  = freeipa
logpath = /var/log/dirsrv/slapd-EXAMPLE-COM/access
datepattern = [%%d/%%m/%%Y:%%H:%%M:%%S]
# action =  # what command to execute (commonly iptables or firewalld commands)

```

jail.conf:
```
[freeipa]
port    = ldaps, ldap
filter  = freeipa
logpath = /var/log/dirsrv/slapd-PREDICTIX-COM/access
datepattern = [%%d/%%m/%%Y:%%H:%%M:%%S]
```

filter.d/freeipa.conf

```
# 289 Access Directory In a FreeIPA server.
#
# Detecting invalid credentials: error code 49

[INCLUDES]

# Read common prefixes. If any customizations available -- read them from
# common.local
#before = common.conf

[Definition]

failregex = ^.* conn=(?P<_conn_>\d+) fd=\d+ slot=\d+ SSL connection from <HOST> to \b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b$<SKIPLINES>^.* conn=(?P=_conn_) op=\d+ RESULT err=49 .* Invalid credentials$

ignoreregex =

[Init]

# "maxlines" is number of log lines to buffer for multi-line regex searches
maxlines = 20
# Author: Ridha Zorgui
```
