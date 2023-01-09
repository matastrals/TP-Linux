# Partie 3 : Configuration et mise en place de NextCloud

## 1. Base de données 

🌞 **Préparation de la base pour NextCloud**

```
[matastral@dbtp5linux ~]$ sudo mysql -u root -p
[sudo] password for matastral:
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 10.5.16-MariaDB MariaDB Server
```
```
MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.000 sec)
```

🌞 **Exploration de la base de données**

```
[matastral@webtp5linux ~]$ mysql -u nextcloud -h 10.105.1.12 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 11
Server version: 5.5.5-10.5.16-MariaDB MariaDB Server
```
```
MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| nextcloud          |
| performance_schema |
+--------------------+
4 rows in set (0.003 sec)
```
```sql
MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| nextcloud          |
| performance_schema |
+--------------------+
4 rows in set (0.003 sec)

MariaDB [(none)]> USE nextcloud;
Database changed
MariaDB [nextcloud]> SHOW TABLES;
Empty set (0.000 sec)
```

🌞 **Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données**

```
MariaDB [mysql]> SELECT user FROM user;
+-------------+
| User        |
+-------------+
| nextcloud   |
| mariadb.sys |
| mysql       |
| root        |
+-------------+
4 rows in set (0.001 sec)
```

## 2. Serveur Web et NextCloud

🌞 **Install de PHP**

```
[matastral@webtp5linux conf]$ sudo dnf config-manager --set-enabled crb
```
```
[matastral@webtp5linux conf]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
```
```
[matastral@webtp5linux conf]$ dnf module list php
```
```
[matastral@webtp5linux conf]$ sudo dnf module enable php:remi-8.1 -y
```
```
[matastral@webtp5linux conf]$ sudo dnf install -y php81-php
```

🌞 **Install de tous les modules PHP nécessaires pour NextCloud**

```
[matastral@webtp5linux conf]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
```

🌞 **Récupérer NextCloud**

```
[matastral@webtp5linux conf]$ sudo mkdir /var/www/tp5_nextcloud/
```
```
[matastral@webtp5linux tp5_nextcloud]$ sudo wget https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
```
```
[matastral@webtp5linux tp5_nextcloud]$ sudo unzip nextcloud-25.0.0rc3.zip
```
```
[matastral@webtp5linux tp5_nextcloud]$ ls nextcloud | grep index
index.html
```
```
[matastral@webtp5linux tp5_nextcloud]$ sudo chown apache nextcloud
```

🌞 **Adapter la configuration d'Apache**

```
[matastral@webtp5linux conf]$ cat httpd.conf | tail -n 1
IncludeOptional conf.d/*.conf
```
```
[matastral@webtp5linux conf.d]$ cat nextcloud.conf
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

🌞 **Redémarrer le service Apache** 

```
[matastral@webtp5linux conf.d]$ sudo systemctl restart httpd
```

## 3. Finaliser l'installation de NextCloud

🌴 **C'est chez vous ici**, baladez vous un peu sur l'interface de NextCloud, faites le tour du propriétaire :)

🌞 **Exploration de la base de données**

```
MariaDB [(none)]> USE nextcloud;
```
```
MariaDB [nextcloud]> SHOW TABLES;
...
95 rows in set (0.001 sec)
```
