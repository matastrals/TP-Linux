# Module 1 : Reverse Proxy
# I. Setup

🖥️ **VM `proxy.tp6.linux`**

🌞 **On utilisera NGINX comme reverse proxy**

```
[matastral@proxytp6linux ~]$ sudo dnf install nginx
```
```
[matastral@proxytp6linux ~]$ sudo systemctl start nginx
```
```
[matastral@proxytp6linux ~]$ sudo ss -alpn | grep nginx
tcp   LISTEN 0      511                                       0.0.0.0:80               0.0.0.0:*     users:(("nginx",pid=1223,fd=6),("nginx",pid=1222,fd=6))
tcp   LISTEN 0      511                                          [::]:80                  [::]:*     users:(("nginx",pid=1223,fd=7),("nginx",pid=1222,fd=7))
```
```
[matastral@proxytp6linux ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[matastral@proxytp6linux ~]$ sudo firewall-cmd --reload
success
[matastral@proxytp6linux ~]$ sudo firewall-cmd --list-all | grep 80
  ports: 80/tcp
```
```
[matastral@proxytp6linux ~]$ ps -ef | grep nginx
nginx       1223    1222  0 10:10 ?        00:00:00 nginx: worker process
```
```
[matastral@proxytp6linux ~]$ curl 10.105.1.3:80 -s | head
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

🌞 **Configurer NGINX**

```
[matastral@proxytp6linux nginx]$ cat nginx.conf | grep conf
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
```
```
[matastral@proxytp6linux conf.d]$ sudo nano reverse-proxy.conf
```
```
[matastral@webtp6linux config]$ sudo cat config.php | head
[sudo] password for matastral:
<?php
$CONFIG = array (
  'instanceid' => 'ochj6awk3l7y',
  'passwordsalt' => '7sn1gzr5U/zSa18gj4AbT3b28LUJcH',
  'secret' => '7ESuVjEYkcVX0B5dYd5n0MTF6bOT68ytgBqgHfHfRucSYn4k',
  'trusted_domains' =>
  array (
    0 => '10.105.1.11',
    1 => '10.105.1.3',
  ),
```
```
[matastral@proxytp6linux nginx]$ cat /etc/nginx/conf.d/reverse-proxy.conf
...
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_pass http://<IP_DE_NEXTCLOUD>:80;
...
```
Ligne en + dans mon fichier host :
```
10.105.1.3      web.tp6.linux
```

🌞 **Faites en sorte de**

```
[matastral@webtp6linux ~]$  sudo firewall-cmd --remove-interface enp0s8 --zone=public --permanent
[matastral@webtp6linux ~]$  sudo firewall-cmd --add-interface enp0s8 --zone=trusted --permanent
[matastral@webtp6linux ~]$  sudo firewall-cmd --add-port=22/tcp --permanent --zone=trusted
[matastral@webtp6linux ~]$  sudo firewall-cmd --add-source=10.105.1.1 --permanent --zone=trusted
[matastral@webtp6linux ~]$  sudo firewall-cmd --permanent --zone=trusted --set-target=DROP
[matastral@webtp6linux ~]$  sudo firewall-cmd --set-default-zone trusted
[matastral@webtp6linux ~]$  sudo firewall-cmd --reload
[matastral@webtp6linux ~]$ sudo firewall-cmd --list-all
trusted (active)
  target: DROP
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources: 10.105.1.1
  services:
  ports: 22/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

🌞 **Une fois que c'est en place**

```
PS C:\Users\matas> ping 10.105.1.11

Envoi d’une requête 'Ping'  10.105.1.11 avec 32 octets de données :
Délai d’attente de la demande dépassé.

Statistiques Ping pour 10.105.1.11:
    Paquets : envoyés = 1, reçus = 0, perdus = 1 (perte 100%),
```
```
PS C:\Users\matas> ping 10.105.1.3

Envoi d’une requête 'Ping'  10.105.1.3 avec 32 octets de données :
Réponse de 10.105.1.3 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.3 : octets=32 temps<1ms TTL=64

Statistiques Ping pour 10.105.1.3:
    Paquets : envoyés = 2, reçus = 2, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 0ms, Maximum = 0ms, Moyenne = 0ms
```

# II. HTTPS

```
[matastral@proxytp6linux conf.d]$ cat reverse-proxy.conf | grep 301
    return 301 https://$host$request_uri;
```
```
[matastral@proxytp6linux conf.d]$ cat reverse-proxy.conf | grep nextcloud
    ssl_certificate /etc/pki/tls/certs/www.nextcloud.tp6.crt;
    ssl_certificate_key /etc/pki/tls/private/www.nextcloud.tp6.key;
```

🌞 **Faire en sorte que NGINX force la connexion en HTTPS plutôt qu'HTTP**

```
[matastral@proxytp6linux conf.d]$ cat reverse-proxy.conf | grep 443
    listen 443 ssl;
```

Pour une magnifique [Partie 2](Partie2.md)