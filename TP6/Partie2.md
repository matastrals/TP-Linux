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

> On a déjà fait ça au TP4 ensemble :)

🖥️ **VM `storage.tp6.linux`**

**N'oubliez pas de dérouler la [📝**checklist**📝](../../2/README.md#checklist).**

🌞 **Préparer un dossier à partager sur le réseau** (sur la machine `storage.tp6.linux`)

- créer un dossier `/srv/nfs_shares`
- créer un sous-dossier `/srv/nfs_shares/web.tp6.linux/`

> Et ouais pour pas que ce soit le bordel, on va appeler le dossier comme la machine qui l'utilisera :)

🌞 **Installer le serveur NFS** (sur la machine `storage.tp6.linux`)

- installer le paquet `nfs-utils`
- créer le fichier `/etc/exports`
  - remplissez avec un contenu adapté
  - j'vous laisse faire les recherches adaptées pour ce faire
- ouvrir les ports firewall nécessaires
- démarrer le service
- je vous laisse check l'internet pour trouver [ce genre de lien](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-rocky-linux-9) pour + de détails

### 2. Client NFS

🌞 **Installer un client NFS sur `web.tp6.linux`**

- il devra monter le dossier `/srv/nfs_shares/web.tp6.linux/` qui se trouve sur `storage.tp6.linux`
- le dossier devra être monté sur `/srv/backup/`
- je vous laisse là encore faire vos recherches pour réaliser ça !
- faites en sorte que le dossier soit automatiquement monté quand la machine s'allume

🌞 **Tester la restauration des données** sinon ça sert à rien :)

- livrez-moi la suite de commande que vous utiliseriez pour restaurer les données dans une version antérieure

![Backup everything](../pics/backup_everything.jpg)