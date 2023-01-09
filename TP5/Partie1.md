# Partie 1 : Mise en place et maîtrise du serveur Web

## 1. Installation

🖥️ **VM web.tp5.linux**

🌞 **Installer le serveur Apache**

```
[matastral@webtp5linux ~]$ sudo dnf install httpd
```

🌞 **Démarrer le service Apache**

```
[matastral@webtp5linux conf]$ sudo systemctl start httpd
[matastral@webtp5linux conf]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
```
```
[matastral@webtp5linux conf]$ sudo ss -alpnt | grep httpd
LISTEN 0      511                *:80              *:*    users:(("httpd",pid=10981,fd=4),("httpd",pid=10980,fd=4),("httpd",pid=10979,fd=4),("httpd",pid=10977,fd=4))
```
```
[matastral@webtp5linux conf]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[matastral@webtp5linux conf]$ sudo firewall-cmd --reload
success
```

🌞 **TEST**

```
[matastral@webtp5linux conf]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor>
     Active: active (running) since Tue 2023-01-03 17:02:23 CET; 12min ago
       Docs: man:httpd.service(8)
   Main PID: 10977 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; B>
      Tasks: 213 (limit: 5905)
     Memory: 23.1M
        CPU: 438ms
```
```
[matastral@webtp5linux conf]$ systemctl is-enabled httpd
enabled
```
```
[matastral@webtp5linux conf]$ curl localhost -s | head -n 10
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
```
```
matas@Mata_milo MINGW64 ~
$ curl http://10.105.1.11 -s
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
        height: 100%;
        width: 100%;
      }
        body {
```

## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

```
[matastral@webtp5linux multi-user.target.wants]$ cat httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

```
[matastral@webtp5linux conf]$ cat httpd.conf | grep User
User apache
```
```
[matastral@webtp5linux conf]$ ps -ef | grep apache
apache       734     708  0 21:03 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```
```
[matastral@webtp5linux testpage]$ sudo chmod 444 index.html
[matastral@webtp5linux testpage]$ ls -al | grep index
-r--r--r--.  1 root root 7620 Jul 27 20:05 index.html
```

🌞 **Changer l'utilisateur utilisé par Apache**

```
[matastral@webtp5linux etc]$ sudo useradd sino -m -s /sbin/nologin -u 3048
```
```
[matastral@webtp5linux conf]$ cat httpd.conf | grep User
User sino
```
```
[matastral@webtp5linux conf]$ sudo systemctl restart httpd
```
```
[matastral@webtp5linux conf]$ ps -ef | grep sino
sino        1232    1230  0 21:56 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

🌞 **Faites en sorte que Apache tourne sur un autre port**

```
[matastral@webtp5linux conf]$ cat httpd.conf | grep Listen
Listen 32454
```
```
[matastral@webtp5linux conf]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[matastral@webtp5linux conf]$ sudo firewall-cmd --add-port=32454/tcp --permanent
success
[matastral@webtp5linux conf]$ sudo firewall-cmd --reload
success
```
```
[matastral@webtp5linux conf]$ sudo systemctl restart httpd
```
```
[matastral@webtp5linux conf]$ sudo ss -alpn | grep 32454
tcp   LISTEN 0      511                                             *:32454                  *:*     users:(("httpd",pid=1506,fd=4),("httpd",pid=1505,fd=4),("httpd",pid=1504,fd=4),("httpd",pid=1501,fd=4))
```
```
[matastral@webtp5linux conf]$ curl 10.105.1.11:32454 -s | head -n 10
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
```
```
PS C:\Users\matas> curl 10.105.1.11:32454
curl : HTTP Server Test Page
This page is used to test the proper operation of an HTTP server after it
has been installed on a Rocky Linux system. If you can read this page, it
means that the software is working correctly.
Just visiting?
```

[fichier conf](./httpd.conf)

La partie 2 ---> [2me partie](./Partie2.md)