# Module 2 : Sauvegarde du système de fichiers

## I. Script de backup

Partie à réaliser sur `web.tp6.linux`.

### 1. Ecriture du script

🌞 **Ecrire le script `bash`**

```
[matastral@webtp6linux srv]$ sudo nano tp6.backup.sh
```
```
[matastral@webtp6linux srv]$ sudo mkdir backup
```
```
[matastral@webtp6linux srv]$ sudo dnf install rsync
```
```bash
[matastral@webtp6linux srv]$ cat tp6.backup.sh
#!/bin/bash

sudo mkdir /srv/backup/nextcloud_`date +"%Y%m%d%k%M%S"`.zip/
rsync -Aavxz /var/www/tp5_nextcloud/data/ /srv/backup/nextcloud_`date +"%Y%m%d%k%M%S"`.zip/data
rsync -Aavxz /var/www/tp5_nextcloud/themes/ /srv/backup/nextcloud_`date +"%Y%m%d%k%M%S"`.zip/themes
rsync -Aavxz /var/www/tp5_nextcloud/config/ /srv/backup/nextcloud_`date +"%Y%m%d%k%M%S"`.zip/config
```
### 2. Clean it

```bash
[matastral@webtp6linux srv]$ cat tp6.backup.sh
#!/bin/bash

#Ecrit le 21/01/2023
#par matastral
#Copie du dossier data, config et themes de nextcloud dans un dossier de backup

dir="nextcloud_`date +"%Y%m%d%k%M%S"`.zip"

sudo mkdir /srv/backup/"$dir"

rsync -Aavxz /var/www/tp5_nextcloud/data/ /srv/backup/"$dir"/data
rsync -Aavxz /var/www/tp5_nextcloud/config/ /srv/backup/"$dir"/config
rsync -Aavxz /var/www/tp5_nextcloud/themes/ /srv/backup/"$dir"/themes
```

➜ **Environnement d'exécution du script**

```
[matastral@webtp6linux srv]$ sudo useradd backup -d /srv/backup -s /usr/bin/
nologin
```
```
[matastral@webtp6linux srv]$ ls -al | grep backup
drwxr-xr-x.  2 backup backup   6 Jan 21 20:28 backup
```

### 3. Service et timer

🌞 **Créez un *service*** système qui lance le script

```
[matastral@webtp6linux system]$ cat backup.service
[Unit]
Description=BackupNextcloud server daemon
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target sshd-keygen.target
Wants=sshd-keygen.target

[Service]
Type=oneshot
EnvironmentFile=-/srv/tp6.backup.sh
ExecStart=/srv/tp6.backup.sh -D $OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
```
```
[matastral@webtp6linux system]$ sudo systemctl daemon-reload
```
```
[matastral@webtp6linux system]$ systemctl status backup.service
○ backup.service - BackupNextcloud server daemon
     Loaded: loaded (/etc/systemd/system/backup.service; disabled; vendor p>
     Active: inactive (dead)
       Docs: man:sshd(8)
             man:sshd_config(5)
```
```
[matastral@webtp6linux system]$ sudo systemctl start backup.service
```

🌞 **Créez un *timer*** système qui lance le *service* à intervalles réguliers

```
[matastral@webtp6linux system]$ cat backup.timer
[Unit]
Description=Run service backup

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
```

🌞 Activez l'utilisation du *timer*

- vous vous servirez des commandes suivantes :

```
[matastral@webtp6linux system]$ sudo systemctl daemon-reload
```
```
[matastral@webtp6linux system]$ sudo systemctl start backup.timer
```
```
[matastral@webtp6linux system]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
```
```
[matastral@webtp6linux system]$ sudo systemctl status backup.timer
● backup.timer - Run service backup
     Loaded: loaded (/etc/systemd/system/backup.timer; enabled; vendor pres>
     Active: active (waiting) since Sat 2023-01-21 21:14:03 CET; 43s ago
      Until: Sat 2023-01-21 21:14:03 CET; 43s ago
    Trigger: Sun 2023-01-22 04:00:00 CET; 6h left
   Triggers: ● backup.service
```
```
[matastral@webtp6linux system]$ sudo systemctl list-timers | grep backup
Sun 2023-01-22 04:00:00 CET 6h left       n/a                         n/a
       backup.timer                 backup.service
```

## II. NFS

### 1. Serveur NFS

🌞 **Préparer un dossier à partager sur le réseau** 

```
[matastral@storagetp6linux ~]$ sudo mkdir /srv/nfs_shares
[matastral@storagetp6linux ~]$ sudo mkdir /srv/nfs_shares/web.tp6.linux
```

🌞 **Installer le serveur NFS** (sur la machine `storage.tp6.linux`)

```
[matastral@storagetp6linux ~]$ sudo dnf install nfs-utils
```
```
[matastral@storagetp6linux ~]$ cat /etc/exports
/srv/nfs_shares/web.tp6.linux/          10.105.1.11(rw,sync,no_subtree_check)
```
```
[matastral@storagetp6linux ~]$ sudo firewall-cmd --permanent --add-service=n
fs
success
[matastral@storagetp6linux ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[matastral@storagetp6linux ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[matastral@storagetp6linux ~]$ sudo firewall-cmd --reload
success
```
```
[matastral@storagetp6linux ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[matastral@storagetp6linux ~]$ sudo systemctl start nfs-server
[matastral@storagetp6linux ~]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; v>
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Sun 2023-01-22 22:06:07 CET; 6s ago
    Process: 2138 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0>
    Process: 2139 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCE>
    Process: 2156 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; >
   Main PID: 2156 (code=exited, status=0/SUCCESS)
        CPU: 14ms
```

### 2. Client NFS

🌞 **Installer un client NFS sur `web.tp6.linux`**

```
[matastral@webtp6linux ~]$ sudo dnf install nfs-utils
```
```
[matastral@webtp6linux ~]$ sudo firewall-cmd --add-source=10.105.1.4 --permanent
[sudo] password for matastral:
success
```
```
[matastral@webtp6linux ~]$ sudo firewall-cmd --reload
success
```
```
[matastral@webtp6linux ~]$ sudo mount 10.105.1.4:/srv/nfs_shares/web.tp6.lin
ux /srv/backup/
[matastral@webtp6linux ~]$ cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Fri Oct 14 08:56:01 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rl-root     /                       xfs     defaults        0 0
UUID=24e07afa-94aa-4137-b350-793d90ff40c5 /boot                   xfs     defaults        0 0
/dev/mapper/rl-swap     none                    swap    defaults        0 0
```

🌞 **Tester la restauration des données** sinon ça sert à rien :)

Pour une [Partie 3](Partie3.md)
