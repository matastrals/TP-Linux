# Partie 2 : Serveur de partage de fichiers


🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

```
[matastral@tp4storagelinux ~]$ sudo dnf install nfs-utils
```
```
[matastral@tp4storagelinux /]$ sudo mkdir -p storage/site_web_1/
[matastral@tp4storagelinux /]$ sudo chown nobody /storage/site_web_1/
[matastral@tp4storagelinux /]$ sudo mkdir /storage/site_web_2/
[matastral@tp4storagelinux /]$ sudo chown nobody /storage/site_web_2/
```
```
[matastral@tp4storagelinux /]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[matastral@tp4storagelinux /]$ sudo systemctl start nfs-server
[matastral@tp4storagelinux /]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Mon 2023-01-02 10:05:43 CET; 7s ago
    Process: 11309 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
    Process: 11310 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 11328 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=e>   Main PID: 11328 (code=exited, status=0/SUCCESS)
        CPU: 12ms

Jan 02 10:05:43 tp4storagelinux systemd[1]: Starting NFS server and services...
Jan 02 10:05:43 tp4storagelinux systemd[1]: Finished NFS server and services.
```
```
[matastral@tp4storagelinux /]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client ssh
[matastral@tp4storagelinux /]$ sudo firewall-cmd --permanent --add-service=nfs
success
[matastral@tp4storagelinux /]$ sudo firewall-cmd --permanent --add-service=mountd
success
[matastral@tp4storagelinux /]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[matastral@tp4storagelinux /]$ sudo firewall-cmd --reload
success
[matastral@tp4storagelinux /]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```
Ici j'affiche les fichier modifié dans le client. C'est plus bas.
```
[matastral@tp4storagelinux /]$ cat storage/site_web_1/yutyrannus
Le premier dino
[matastral@tp4storagelinux /]$ cat storage/site_web_2/pachycephalosaure
Le second dino
```
🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

```
[matastral@tp4weblinux site_web_2]$ sudo dnf install nfs-utils
```
```
[matastral@tp4weblinux site_web_2]$ sudo mkdir -p /var/www/site_web_2/
[matastral@tp4weblinux site_web_2]$ sudo mkdir -p /var/www/site_web_1/
```
```
[matastral@tp4weblinux site_web_2]$ sudo mount 10.3.2.14:/storage/site_web_1/ /var/www/site_web_1/
[matastral@tp4weblinux site_web_2]$ sudo mount 10.3.2.14:/storage/site_web_2 /var/www/site_web_2/
```
```
[matastral@tp4weblinux site_web_2]$ df -h
Filesystem                     Size  Used Avail Use% Mounted on
devtmpfs                       462M     0  462M   0% /dev
tmpfs                          481M     0  481M   0% /dev/shm
tmpfs                          193M  3.0M  190M   2% /run
/dev/mapper/rl-root            6.2G  1.2G  5.1G  18% /
/dev/sda1                     1014M  210M  805M  21% /boot
tmpfs                           97M     0   97M   0% /run/user/1000
10.3.2.14:/storage/site_web_1  6.2G  1.2G  5.1G  18% /var/www/site_web_1
10.3.2.14:/storage/site_web_2  6.2G  1.2G  5.1G  18% /var/www/site_web_2
```
```
[matastral@tp4weblinux /]$ sudo nano etc/fstab
[matastral@tp4weblinux /]$ sudo cat etc/fstab
...
10.3.2.14:/storage/site_web_1/    /var/www/site_web_1/   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
10.3.2.14:/storage/site_web_2/    /var/www/site_web_2/      nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```
```
[matastral@tp4weblinux site_web_1]$ sudo touch yutyrannus
[matastral@tp4weblinux site_web_2]$ sudo touch pachycephalosaure
```
Ici je modifie 2 fichier. J'affiche leur contenus plus haut.
```
[matastral@tp4weblinux /]$ sudo nano var/www/site_web_1/yutyrannus
[matastral@tp4weblinux /]$ sudo nano var/www/site_web_2/pachycephalosaure
```

Pour la partie 3 ---> [Partie3](./Partie3.md) <---