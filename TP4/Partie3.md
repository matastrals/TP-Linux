# Partie 3 : Serveur web

## 1. Intro NGINX

## 2. Install

🖥️ **VM web.tp4.linux**

🌞 **Installez NGINX**

```
[matastral@tp4weblinux /]$ sudo dnf install nginx
```

## 3. Analyse

🌞 **Analysez le service NGINX**

```
[matastral@tp4weblinux /]$ ps -ef | grep nginx
root        2276       1  0 11:22 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       2277    2276  0 11:22 ?        00:00:00 nginx: worker process
```
```
[matastral@tp4weblinux /]$ sudo ss -alnp | grep nginx
[sudo] password for matastral:
tcp   LISTEN 0      511                                       0.0.0.0:80               0.0.0.0:*     users:(("nginx",pid=2277,fd=6),("nginx",pid=2276,fd=6))
tcp   LISTEN 0      511                                          [::]:80                  [::]:*     users:(("nginx",pid=2277,fd=7),("nginx",pid=2276,fd=7))
```
```
[matastral@tp4weblinux nginx]$ grep -nri 'root'
nginx.conf:42:        root         /usr/share/nginx/html;
```
```
[matastral@tp4weblinux nginx]$ ls -l
total 0
drwxr-xr-x. 3 root root 143 Jan  2 11:20 html
```

## 4. Visite du service web

🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX**

```
[matastral@tp4weblinux nginx]$ sudo firewall-cmd --add-port=80/tcp --permanent
[sudo] password for matastral:
success
[matastral@tp4weblinux nginx]$ sudo firewall-cmd --reload
success
```

🌞 **Accéder au site web**

```
[matastral@tp4weblinux nginx]$ curl http://10.3.2.15 -s | head
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

🌞 **Vérifier les logs d'accès**

```
[matastral@tp4weblinux nginx]$ grep -nri 'log'
nginx.conf:22:    access_log  /var/log/nginx/access.log  main;
```
```
[matastral@tp4weblinux /]$ sudo cat var/log/nginx/access.log | tail -n 3
10.3.2.15 - - [02/Jan/2023:11:45:45 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
10.3.2.15 - - [02/Jan/2023:11:45:53 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
```

## 5. Modif de la conf du serveur web

🌞 **Changer le port d'écoute**

```
[matastral@tp4weblinux nginx]$ cat nginx.conf | grep listen
        listen       8080;
        listen       [::]:8080;
```
```
[matastral@tp4weblinux /]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success
[matastral@tp4weblinux /]$ sudo nano etc/nginx/nginx.conf
[matastral@tp4weblinux nginx]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[matastral@tp4weblinux nginx]$ sudo firewall-cmd --reload
success
```
```
[matastral@tp4weblinux /]$ sudo systemctl restart nginx
[matastral@tp4weblinux /]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendo>
     Active: active (running) since Mon 2023-01-02 11:58:15 CET; 7s ago
    Process: 2430 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, >
    Process: 2432 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SU>
    Process: 2433 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 2434 (nginx)
      Tasks: 2 (limit: 5905)
     Memory: 1.9M
        CPU: 12ms
     CGroup: /system.slice/nginx.service
             ├─2434 "nginx: master process /usr/sbin/nginx"
             └─2435 "nginx: worker process"
```
```
[matastral@tp4weblinux /]$ sudo ss -alpn | grep nginx
tcp   LISTEN 0      511                                       0.0.0.0:8080             0.0.0.0:*     users:(("nginx",pid=2435,fd=6),("nginx",pid=2434,fd=6))
tcp   LISTEN 0      511                                          [::]:8080                [::]:*     users:(("nginx",pid=2435,fd=7),("nginx",pid=2434,fd=7))
```
```
[matastral@tp4weblinux nginx]$ curl http://10.3.2.15:8080 -s | head
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

🌞 **Changer l'utilisateur qui lance le service**

```
[matastral@tp4weblinux /]$ sudo useradd web -m -d /home/web
[matastral@tp4weblinux home]$ sudo passwd web
Changing password for user web.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication tokens updated successfully.
```
```
[matastral@tp4weblinux nginx]$ cat nginx.conf | grep user
user web;
```
```
[matastral@tp4weblinux nginx]$ sudo systemctl restart nginx
[matastral@tp4weblinux nginx]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendo>
     Active: active (running) since Mon 2023-01-02 12:22:05 CET; 10s ago
    Process: 2568 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, >
    Process: 2569 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SU>
    Process: 2570 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 2571 (nginx)
      Tasks: 2 (limit: 5905)
     Memory: 1.9M
        CPU: 13ms
     CGroup: /system.slice/nginx.service
             ├─2571 "nginx: master process /usr/sbin/nginx"
             └─2572 "nginx: worker process"
```
```
[matastral@tp4weblinux nginx]$ ps -ef | grep web
web         2572    2571  0 12:22 ?        00:00:00 nginx: worker process
```

🌞 **Changer l'emplacement de la racine Web**

```
[matastral@tp4weblinux nginx]$ cat /var/www/site_web_1/index.html
J'aime les dinosaures.
```
```
[matastral@tp4weblinux nginx]$ cat nginx.conf | grep www
        root         /var/www/site_web_1/;
```
```
[matastral@tp4weblinux nginx]$ curl http://10.3.2.15:8080 -s
J'aime les dinosaures.
```

## 6. Deux sites web sur un seul serveur

🌞 **Repérez dans le fichier de conf**

```
[matastral@tp4weblinux nginx]$ cat nginx.conf | grep include
include /etc/nginx/conf.d/*.conf;
```

🌞 **Créez le fichier de configuration pour le premier site**

```
[matastral@tp4weblinux nginx]$ cat conf.d/site_web_1.conf
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

🌞 **Créez le fichier de configuration pour le deuxième site**

```
[matastral@tp4weblinux nginx]$ sudo nano conf.d/site_web_2.conf
```
```
[matastral@tp4weblinux nginx]$ cat conf.d/site_web_1.conf
    server {
        listen       8888;
        listen       [::]:8888;
        server_name  _;
        root         /var/www/site_web_2/;

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

🌞 **Prouvez que les deux sites sont disponibles**

```
PS C:\Users\matas> curl http://10.3.2.15:8888


StatusCode        : 200
StatusDescription : OK
Content           : Le dodo est si faible qu'il a disparu trÃ¨s vite.

RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 50
                    Content-Type: text/html
                    Date: Mon, 02 Jan 2023 22:52:46 GMT
                    ETag: "63b35fc5-32"
                    Last-Modified: Mon, 02 Jan 2023 22...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 50], [Content-Type, text/html]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 50
```
```
PS C:\Users\matas> curl http://10.3.2.15:8080


StatusCode        : 200
StatusDescription : OK
Content           : <!doctype html>
                    <html>
                      <head>
                        <meta charset='utf-8'>
                        <meta name='viewport' content='width=device-width,
                    initial-scale=1'>
                        <title>HTTP Server Test Page powered by: Rocky
                    Linux</title>
                       ...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 7620
                    Content-Type: text/html
                    Date: Mon, 02 Jan 2023 22:53:20 GMT
                    ETag: "62e17e64-1dc4"
                    Last-Modified: Wed, 27 Jul 202...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 7620], [Content-Type, text/html]...}
Images            : {@{innerHTML=; innerText=; outerHTML=<IMG alt="[
                    Powered by Rocky Linux ]" src="icons/poweredby.png">;
                    outerText=; tagName=IMG; alt=[ Powered by Rocky Linux
                    ]; src=icons/poweredby.png}, @{innerHTML=; innerText=;
                    outerHTML=<IMG src="poweredby.png">; outerText=;
                    tagName=IMG; src=poweredby.png}}
InputFields       : {}
Links             : {@{innerHTML=<STRONG>Rocky Linux website</STRONG>;
                    innerText=Rocky Linux website; outerHTML=<A
                    href="https://rockylinux.org/"><STRONG>Rocky Linux
                    website</STRONG></A>; outerText=Rocky Linux website;
                    tagName=A; href=https://rockylinux.org/},
                    @{innerHTML=Apache Webserver</STRONG>;
                    innerText=Apache Webserver; outerHTML=<A
                    href="https://httpd.apache.org/">Apache
                    Webserver</STRONG></A>; outerText=Apache Webserver;
                    tagName=A; href=https://httpd.apache.org/},
                    @{innerHTML=Nginx</STRONG>; innerText=Nginx;
                    outerHTML=<A
                    href="https://nginx.org">Nginx</STRONG></A>;
                    outerText=Nginx; tagName=A; href=https://nginx.org},
                    @{innerHTML=<IMG alt="[ Powered by Rocky Linux ]"
                    src="icons/poweredby.png">; innerText=; outerHTML=<A
                    id=rocky-poweredby href="https://rockylinux.org/"><IMG
                    alt="[ Powered by Rocky Linux ]"
                    src="icons/poweredby.png"></A>; outerText=; tagName=A;
                    id=rocky-poweredby; href=https://rockylinux.org/}...}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 7620
```