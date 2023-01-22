# Module 4 : Monitoring

🌞 **Installer Netdata**

```
[matastral@webtp6linux ~]$ wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh
```
```
[matastral@webtp6linux ~]$ sudo systemctl start netdata
[matastral@webtp6linux ~]$ sudo systemctl enable netdata
[matastral@webtp6linux ~]$ sudo systemctl status netdata
● netdata.service - Real time performance monitoring
     Loaded: loaded (/usr/lib/systemd/system/netdata.service; enabled; vend>
     Active: active (running) since Sun 2023-01-22 23:00:20 CET; 1min 23s a>
   Main PID: 2978 (netdata)
      Tasks: 78 (limit: 4638)
     Memory: 145.7M
        CPU: 3.772s
     CGroup: /system.slice/netdata.service
             ├─2978 /usr/sbin/netdata -P /run/netdata/netdata.pid -D
             ├─2982 /usr/sbin/netdata --special-spawn-server
             ├─3208 bash /usr/libexec/netdata/plugins.d/tc-qos-helper.sh 1
             ├─3213 /usr/libexec/netdata/plugins.d/apps.plugin 1
             ├─3215 /usr/libexec/netdata/plugins.d/ebpf.plugin 1
             └─3217 /usr/libexec/netdata/plugins.d/go.d.plugin 1
```
```
[matastral@webtp6linux ~]$ sudo firewall-cmd --add-port=19999/tcp --permanen
t
success
[matastral@webtp6linux ~]$ sudo firewall-cmd --reload
success
```
```
[matastral@webtp6linux ~]$ sudo ss -alpn | grep 19999
tcp   LISTEN 0      4096
        0.0.0.0:19999            0.0.0.0:*    users:(("netdata",pid=2978,fd=6))
```

🌞 **Une fois Netdata installé et fonctionnel, déterminer :**

```
netdata     2978  1.1  7.2 482332 57072 ?        SNsl 23:00   0:09 /usr/sbin/netdata -P /run/netdata/netdata.pid -D
netdata     2982  0.0  1.1  28772  8664 ?        SNl  23:00   0:00 /usr/sbin/netdata --special-spawn-server
netdata     3208  0.0  0.4   4504  3236 ?        SN   23:00   0:00 bash /usr/libexec/netdata/plugins.d/tc-qos-helper.sh 1
netdata     3213  0.9  1.3 134396 10284 ?        SNl  23:00   0:08 /usr/libexec/netdata/plugins.d/apps.plugin 1
netdata     3217  0.2  6.5 773716 51100 ?        SNl  23:00   0:02 /usr/libexec/netdata/plugins.d/go.d.plugin 1
```
```
[matastral@webtp6linux ~]$ sudo ss -alpn | grep netdata
u_str LISTEN 0      4096                                                   /tmp/netdata-ipc 33026                  * 0    users:(("netdata",pid=2978,fd=53))

udp   UNCONN 0      0                                                             127.0.0.1:8125             0.0.0.0:*    users:(("netdata",pid=2978,fd=39))

udp   UNCONN 0      0                                                                 [::1]:8125                [::]:*    users:(("netdata",pid=2978,fd=38))

tcp   LISTEN 0      4096                                                          127.0.0.1:8125             0.0.0.0:*    users:(("netdata",pid=2978,fd=71))

tcp   LISTEN 0      4096                                                            0.0.0.0:19999            0.0.0.0:*    users:(("netdata",pid=2978,fd=6)) 

tcp   LISTEN 0      4096                                                              [::1]:8125                [::]:*    users:(("netdata",pid=2978,fd=70))

tcp   LISTEN 0      4096                                                               [::]:19999               [::]:*    users:(("netdata",pid=2978,fd=7)) 
```
```
[matastral@webtp6linux ~]$ sudo journalctl -xeu netdata
```

🌞 **Configurer Netdata pour qu'il vous envoie des alertes** 

```
[matastral@webtp6linux ~]$ cat /etc/netdata/health_alarm_notify.conf | grep discord
# sending discord notifications
# enable/disable sending discord notifications
# https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1064492175976566824/hPDcaiu7PRbmkeiDOnMkfOFuM1wRU295WNE2EVXMzvPnpLthiSLyw3-s9-g7yTVIkLrh"
# this discord channel (empty = do not send a notification for unconfigured
role_recipients_discord[sysadmin]="systems"
role_recipients_discord[dba]="databases systems"
role_recipients_discord[webmaster]="marketing development"
```
```
[matastral@webtp6linux ~]$ sudo systemctl restart netdata
```
```
[matastral@webtp6linux ~]$ stress --cpu 1
stress: info: [15910] dispatching hogs: 1 cpu, 0 io, 0 vm, 0 hdd
```
```
[matastral@webtp6linux ~]$ cat health.d/cpu.conf | head -n 19

# you can disable an alarm notification by setting the 'to' line to: silent

 template: 10min_cpu_usage
       on: system.cpu
    class: Utilization
     type: System
component: CPU
       os: linux
    hosts: *
   lookup: average -10m unaligned of user,system,softirq,irq,guest
    units: %
    every: 1min
     warn: $this > 10
     crit: $this > (($status == $CRITICAL) ? (85) : (95))
    delay: down 15m multiplier 1.5 max 1h
     info: average CPU utilization over the last 10 minutes (excluding iowait, nice and steal)
       to: sysadmin

```

🌞 **Vérifier que les alertes fonctionnent**

- en surchargeant volontairement la machine 
- par exemple, effectuez des *stress tests* de RAM et CPU, ou remplissez le disque volontairement
- demandez au grand Internet comme on peut "stress" une machine (c'est le terme technique)

![Monitoring](../pics/monit.jpg)