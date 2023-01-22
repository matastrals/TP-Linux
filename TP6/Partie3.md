# Module 3 : Fail2Ban

🌞 Faites en sorte que :

```
[matastral@dbtp5linux ~]$ sudo dnf install epel-release
[matastral@dbtp5linux ~]$ sudo dnf install fail2ban-firewalld
```
```
[matastral@dbtp5linux ~]$ sudo systemctl start fail2ban
[matastral@dbtp5linux ~]$ sudo systemctl enable fail2ban
Created symlink /etc/systemd/system/multi-user.target.wants/fail2ban.service → /usr/lib/systemd/system/fail2ban.service.
[matastral@dbtp5linux ~]$ sudo systemctl status fail2ban
● fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; enabled; ven>
     Active: active (running) since Sun 2023-01-22 22:34:09 CET; 58s ago
       Docs: man:fail2ban(1)
   Main PID: 12302 (fail2ban-server)
      Tasks: 3 (limit: 5905)
     Memory: 10.3M
        CPU: 92ms
     CGroup: /system.slice/fail2ban.service
             └─12302 /usr/bin/python3 -s /usr/bin/fail2ban-server -xf start
```
```
[matastral@dbtp5linux ~]$ sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
[matastral@dbtp5linux ~]$ sudo mv /etc/fail2ban/jail.d/00-firewalld.conf /etc/fail2ban/jail.d/00-firewalld.local
```
```
[matastral@dbtp5linux ~]$ sudo systemctl restart fail2ban
```
```
[matastral@dbtp5linux ~]$ sudo cat /etc/fail2ban/jail.d/sshd.local
[sshd]
enabled = true

# Override the default global configuration
# for specific jail sshd
bantime = 1d
findtime = 1min
maxretry = 3
```
```
[matastral@dbtp5linux ~]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     3
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 1
   |- Total banned:     1
   `- Banned IP list:   10.105.1.11
```
```
[matastral@dbtp5linux ~]$ sudo firewall-cmd --list-all | grep ssh
  services: cockpit dhcpv6-client ssh
        rule family="ipv4" source address="10.105.1.11" port port="ssh" protocol="tcp" reject type="icmp-port-unreachable"
```
```
[matastral@dbtp5linux ~]$ sudo fail2ban-client unban 10.105.1.11
1
[matastral@dbtp5linux ~]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     3
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 0
   |- Total banned:     1
   `- Banned IP list:
```

Et enfin la [Partie 4](Partie4.md)