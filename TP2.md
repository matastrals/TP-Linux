# TP2 : Appréhender l'environnement Linux

# I. Service SSH

## 1. Analyse du service

🌞 **S'assurer que le service sshd est démarré**

```
[matastral@tp2-linux /]$ systemctl status sshd.service
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor >
     Active: active (running) since Mon 2022-12-05 11:13:57 CET; 13min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 706 (sshd)
      Tasks: 1 (limit: 5905)
     Memory: 5.6M
        CPU: 63ms
     CGroup: /system.slice/sshd.service
             └─706 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Dec 05 11:13:57 tp2-linux systemd[1]: Starting OpenSSH server daemon...
Dec 05 11:13:57 tp2-linux sshd[706]: Server listening on 0.0.0.0 port 22.
Dec 05 11:13:57 tp2-linux sshd[706]: Server listening on :: port 22.
Dec 05 11:13:57 tp2-linux systemd[1]: Started OpenSSH server daemon.
Dec 05 11:14:07 tp2-linux sshd[844]: Accepted password for matastral from 1>
Dec 05 11:14:07 tp2-linux sshd[844]: pam_unix(sshd:session): session opened>
```

🌞 **Analyser les processus liés au service SSH**

```
[matastral@tp2-linux /]$ ps -ef | grep sshd
root         706       1  0 11:13 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root         844     706  0 11:14 ?        00:00:00 sshd: matastral [priv]
matastr+     848     844  0 11:14 ?        00:00:00 sshd: matastral@pts/0
matastr+     898     849  0 11:30 pts/0    00:00:00 grep --color=auto sshd
```

🌞 **Déterminer le port sur lequel écoute le service SSH**

```
[matastral@tp2-linux /]$ sudo ss -alnpt | grep ssh
[sudo] password for matastral:
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=706,fd=3))
LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=706,fd=4))
```

🌞 **Consulter les logs du service SSH**

```
[matastral@tp2-linux /]$ journalctl -xe -u sshd -f
Dec 05 11:13:57 tp2-linux systemd[1]: Starting OpenSSH server daemon...
░░ Subject: A start job for unit sshd.service has begun execution
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ A start job for unit sshd.service has begun execution.
░░
░░ The job identifier is 229.
Dec 05 11:13:57 tp2-linux sshd[706]: Server listening on 0.0.0.0 port 22.
Dec 05 11:13:57 tp2-linux sshd[706]: Server listening on :: port 22.
Dec 05 11:13:57 tp2-linux systemd[1]: Started OpenSSH server daemon.
░░ Subject: A start job for unit sshd.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ A start job for unit sshd.service has finished successfully.
░░
░░ The job identifier is 229.
Dec 05 11:14:07 tp2-linux sshd[844]: Accepted password for matastral from 10.3.2.1 port 54910 ssh2
Dec 05 11:14:07 tp2-linux sshd[844]: pam_unix(sshd:session): session opened for user matastral(uid=1000) by (uid=0)
```
```
[matastral@tp2-linux log]$ sudo tail -n 10 secure
Dec  5 11:40:55 tp2-linux sudo[908]: pam_unix(sudo:session): session closed for user root
Dec  5 11:41:00 tp2-linux sudo[913]: matastral : TTY=pts/0 ; PWD=/var ; USER=root ; COMMAND=/bin/nano log tail -n -10
Dec  5 11:41:00 tp2-linux sudo[913]: pam_unix(sudo:session): session opened for user root(uid=0) by matastral(uid=1000)
Dec  5 11:41:00 tp2-linux sudo[913]: pam_unix(sudo:session): session closed for user root
Dec  5 11:41:10 tp2-linux sudo[916]: matastral : TTY=pts/0 ; PWD=/var ; USER=root ; COMMAND=/bin/nano tail -n -10 log
Dec  5 11:41:10 tp2-linux sudo[916]: pam_unix(sudo:session): session opened for user root(uid=0) by matastral(uid=1000)
Dec  5 11:41:10 tp2-linux sudo[916]: pam_unix(sudo:session): session closed for user root
Dec  5 11:41:52 tp2-linux sudo[919]: matastral : TTY=pts/0 ; PWD=/var ; USER=root ; COMMAND=/bin/tail -n 10 log
Dec  5 11:41:52 tp2-linux sudo[919]: pam_unix(sudo:session): session opened for user root(uid=0) by matastral(uid=1000)
Dec  5 11:41:52 tp2-linux sudo[919]: pam_unix(sudo:session): session closed for user root
```

## 2. Modification du service

🌞 **Identifier le fichier de configuration du serveur SSH**

```
[matastral@tp2-linux ssh]$ sudo nano /etc/ssh/sshd_config
```

🌞 **Modifier le fichier de conf**

```
[matastral@tp2-linux ssh]$ echo $RANDOM
5012
```
```
[matastral@tp2-linux ssh]$ sudo cat sshd_config | grep Port
Port 5012
```
```
[matastral@tp2-linux ssh]$ sudo firewall-cmd --remove-service=ssh --permanent
success
```
```
[matastral@tp2-linux ssh]$ sudo firewall-cmd --add-port=5012/tcp --permanent
success
```
```
[matastral@tp2-linux ssh]$ sudo firewall-cmd --reload
success
```
```
[matastral@tp2-linux ssh]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 5012/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
🌞 **Redémarrer le service**
```
[matastral@tp2-linux ssh]$ sudo systemctl restart sshd
```
🌞 **Effectuer une connexion SSH sur le nouveau port**
```
PS C:\Users\matas> ssh -p 5012 matastral@10.3.2.11
matastral@10.3.2.11's password:
Last login: Mon Dec  5 12:20:56 2022
```

✨ **Bonus : affiner la conf du serveur SSH**

- faites vos plus belles recherches internet pour améliorer la conf de SSH
- par "améliorer" on entend essentiellement ici : augmenter son niveau de sécurité
- le but c'est pas de me rendre 10000 lignes de conf que vous pompez sur internet pour le bonus, mais de vous éveiller à divers aspects de SSH, la sécu ou d'autres choses liées

# II. Service HTTP

## 1. Mise en place

![nngijgingingingijijnx ?](./pics/njgjgijigngignx.jpg)

🌞 **Installer le serveur NGINX**

```
[matastral@tp2-linux ~]$ sudo dnf install nginx
[sudo] password for matastral:
Rocky Linux 9 - BaseOS                      6.6 kB/s | 3.6 kB     00:00
Rocky Linux 9 - BaseOS                      1.9 MB/s | 1.7 MB     00:00
Rocky Linux 9 - AppStream                   9.3 kB/s | 4.1 kB     00:00
Rocky Linux 9 - AppStream                   6.6 MB/s | 6.4 MB     00:00
Rocky Linux 9 - Extras                      5.7 kB/s | 2.9 kB     00:00
Rocky Linux 9 - Extras                       13 kB/s | 6.6 kB     00:00
Dependencies resolved.
============================================================================
 Package               Arch       Version               Repository     Size
============================================================================
Installing:
 nginx                 x86_64     1:1.20.1-13.el9       appstream      38 k
Installing dependencies:
 nginx-core            x86_64     1:1.20.1-13.el9       appstream     567 k
 nginx-filesystem      noarch     1:1.20.1-13.el9       appstream      11 k
 rocky-logos-httpd     noarch     90.13-1.el9           appstream      24 k

Transaction Summary
============================================================================
Install  4 Packages

Total download size: 640 k
Installed size: 1.8 M
Is this ok [y/N]: y
Downloading Packages:
(1/4): nginx-filesystem-1.20.1-13.el9.noarc  95 kB/s |  11 kB     00:00
(2/4): rocky-logos-httpd-90.13-1.el9.noarch 166 kB/s |  24 kB     00:00
(3/4): nginx-1.20.1-13.el9.x86_64.rpm       254 kB/s |  38 kB     00:00
(4/4): nginx-core-1.20.1-13.el9.x86_64.rpm  3.2 MB/s | 567 kB     00:00
----------------------------------------------------------------------------
Total                                       918 kB/s | 640 kB     00:00
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                    1/1
  Running scriptlet: nginx-filesystem-1:1.20.1-13.el9.noarch            1/4
  Installing       : nginx-filesystem-1:1.20.1-13.el9.noarch            1/4
  Installing       : nginx-core-1:1.20.1-13.el9.x86_64                  2/4
  Installing       : rocky-logos-httpd-90.13-1.el9.noarch               3/4
  Installing       : nginx-1:1.20.1-13.el9.x86_64                       4/4
  Running scriptlet: nginx-1:1.20.1-13.el9.x86_64                       4/4
  Verifying        : rocky-logos-httpd-90.13-1.el9.noarch               1/4
  Verifying        : nginx-filesystem-1:1.20.1-13.el9.noarch            2/4
  Verifying        : nginx-1:1.20.1-13.el9.x86_64                       3/4
  Verifying        : nginx-core-1:1.20.1-13.el9.x86_64                  4/4

Installed:
  nginx-1:1.20.1-13.el9.x86_64
  nginx-core-1:1.20.1-13.el9.x86_64
  nginx-filesystem-1:1.20.1-13.el9.noarch
  rocky-logos-httpd-90.13-1.el9.noarch

Complete!
```
🌞 **Démarrer le service NGINX**

```
[matastral@tp2-linux ~]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
```

🌞 **Déterminer sur quel port tourne NGINX**

```
[matastral@tp2-linux ~]$ sudo ss -alnpt | grep nginx
[sudo] password for matastral:
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=10815,fd=6),("nginx",pid=10814,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=10815,fd=7),("nginx",pid=10814,fd=7))
```
```
[matastral@tp2-linux ~]$ sudo firewall-cmd --permanent --add-service=http
success
[matastral@tp2-linux ~]$ sudo firewall-cmd --permanent --list-all
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client http
  ports: 22/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[matastral@tp2-linux ~]$ sudo firewall-cmd --reload
success
```

🌞 **Déterminer les processus liés à l'exécution de NGINX**

```
[matastral@tp2-linux ~]$ ps -ef | grep nginx
root       10814       1  0 10:19 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx      10815   10814  0 10:19 ?        00:00:00 nginx: worker process
matastr+   10834     850  0 10:40 pts/0    00:00:00 grep --color=auto nginx
```

🌞 **Euh wait**

```
[matastral@tp2-linux ~]$ sudo systemctl status nginx
[sudo] password for matastral:
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor>
     Active: active (running) since Tue 2022-12-06 10:19:47 CET; 21min ago
    Process: 10811 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited,>
    Process: 10812 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/S>
    Process: 10813 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 10814 (nginx)
      Tasks: 2 (limit: 5905)
     Memory: 1.9M
        CPU: 14ms
```
```
$ curl 10.3.2.11 | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0   652k      0 --:--:-- --:--:-- --:--:--  676k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
```

## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

```
[matastral@tp2-linux nginx]$ ls -al /etc/nginx/nginx.conf
-rw-r--r--. 1 root root 2334 Oct 31 16:37 /etc/nginx/nginx.conf
```

🌞 **Trouver dans le fichier de conf**

```
[matastral@tp2-linux nginx]$ cat nginx.conf | grep server -A 16
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```
```
[matastral@tp2-linux nginx]$ cat nginx.conf | grep conf
# For more information on configuration, see:
include /usr/share/nginx/modules/*.conf;
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
```

## 3. Déployer un nouveau site web

🌞 **Créer un site web**

```
[matastral@tp2-linux var]$ sudo mkdir www
[sudo] password for matastral:
[matastral@tp2-linux www]$ sudo mkdir tp2_linux
```
```
[matastral@tp2-linux tp2_linux]$ sudo nano index.html
[matastral@tp2-linux tp2_linux]$ cat index.html
<h1>MEOW mon premier serveur web</h1>
```

🌞 **Adapter la conf NGINX**

```
[matastral@tp2-linux conf.d]$ sudo nano server.conf
[matastral@tp2-linux conf.d]$ sudo systemctl restart nginx
[matastral@tp2-linux conf.d]$ sudo cat server.conf
[sudo] password for matastral:
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen 13555;

  root /var/www/tp2_linux;
}
```

🌞 **Visitez votre super site web**

```
$ curl 10.3.2.11:13555
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    38  100    38    0     0  17335      0 --:--:-- --:--:-- --:--:-- 38000<1>MEOW mon premier serveur web</h1>
```

# III. Your own services

## 1. Au cas où vous auriez oublié

## 2. Analyse des services existants

🌞 **Afficher le fichier de service SSH**

```
[matastral@tp2-linux system]$ cat sshd.service | grep ExecStart=
ExecStart=/usr/sbin/sshd -D $OPTIONS
```

🌞 **Afficher le fichier de service NGINX**

```
ExecStart=/usr/sbin/nginx
```

## 3. Création de service

🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**

```
[matastral@tp2-linux system]$ sudo nano tp2_nc.service
[matastral@tp2-linux system]$ echo $RANDOM
27783
```

🌞 **Indiquer au système qu'on a modifié les fichiers de service**

```
[matastral@tp2-linux system]$ sudo systemctl daemon-reload
```

🌞 **Démarrer notre service de ouf**

```
[matastral@tp2-linux system]$ sudo systemctl start tp2_nc.service
```

🌞 **Vérifier que ça fonctionne**

```
[matastral@tp2-linux system]$ systemctl status tp2_nc.service
● tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/usr/lib/systemd/system/tp2_nc.service; static)
     Active: active (running) since Thu 2022-12-08 21:18:01 CET; 22s ago
   Main PID: 1337 (nc)
      Tasks: 1 (limit: 5905)
     Memory: 788.0K
        CPU: 2ms
     CGroup: /system.slice/tp2_nc.service
             └─1337 /usr/bin/nc -l 27783

Dec 08 21:18:01 tp2-linux systemd[1]: Started Super netcat tout fou.
```
```
[matastral@tp2-linux system]$ sudo ss -alpnt | grep nc
LISTEN 0      10           0.0.0.0:27783      0.0.0.0:*    users:(("nc",pid=1337,fd=4))
LISTEN 0      10              [::]:27783         [::]:*    users:(("nc",pid=1337,fd=3))
```
```
[matastral@localhost ~]$ nc 10.3.2.11 27783
allo
```

🌞 **Les logs de votre service**

```
[matastral@tp2-linux system]$ sudo journalctl -xe -u tp2_nc -f | grep Started
Dec 08 21:18:01 tp2-linux systemd[1]: Started Super netcat tout fou.
```
```
[matastral@tp2-linux system]$ sudo journalctl -xe -u tp2_nc -f | grep allo
Dec 08 21:30:50 tp2-linux nc[1404]: allo
```
```
[matastral@tp2-linux system]$ sudo journalctl -xe -u tp2_nc -f | grep Deactivated
Dec 08 21:22:13 tp2-linux systemd[1]: tp2_nc.service: Deactivated successfully.
```

🌞 **Affiner la définition du service**

```
[matastral@tp2-linux system]$ sudo journalctl -xe -u tp2_nc -f | grep 21:43
Dec 08 21:43:08 tp2-linux systemd[1]: tp2_nc.service: Deactivated successfully.
Dec 08 21:43:08 tp2-linux systemd[1]: tp2_nc.service: Scheduled restart job, restart counter is at 3.
Dec 08 21:43:08 tp2-linux systemd[1]: Stopped Super netcat tout fou.
Dec 08 21:43:08 tp2-linux systemd[1]: Started Super netcat tout fou.
Dec 08 21:43:11 tp2-linux nc[1496]: coucou
Dec 08 21:43:14 tp2-linux nc[1496]: Leo
Dec 08 21:43:15 tp2-linux systemd[1]: tp2_nc.service: Deactivated successfully.
Dec 08 21:43:16 tp2-linux systemd[1]: tp2_nc.service: Scheduled restart job, restart counter is at 4.
Dec 08 21:43:16 tp2-linux systemd[1]: Stopped Super netcat tout fou.
Dec 08 21:43:16 tp2-linux systemd[1]: Started Super netcat tout fou.
Dec 08 21:43:22 tp2-linux nc[1497]: Tu vas bien ?
Dec 08 21:43:22 tp2-linux systemd[1]: tp2_nc.service: Deactivated successfully.
Dec 08 21:43:23 tp2-linux systemd[1]: tp2_nc.service: Scheduled restart job, restart counter is at 5.
Dec 08 21:43:23 tp2-linux systemd[1]: Stopped Super netcat tout fou.
Dec 08 21:43:23 tp2-linux systemd[1]: Started Super netcat tout fou.
```
