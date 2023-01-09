# Partie 2 : Mise en place et maîtrise du serveur de base de données

🌞 **Install de MariaDB sur `db.tp5.linux`**

```
[matastral@dbtp5linux ~]$ sudo dnf install mariadb-server
```
```
[matastral@dbtp5linux ~]$ sudo systemctl enable mariadb
```
```
[matastral@dbtp5linux ~]$ sudo systemctl start mariadb
```
```
[matastral@dbtp5linux ~]$ sudo mysql_secure_installation
```
```
[matastral@dbtp5linux ~]$ sudo systemctl is-enabled mariadb
enabled
```
🌞 **Port utilisé par MariaDB**

```
[matastral@dbtp5linux ~]$ sudo ss -alpn | grep mariadb
tcp   LISTEN 0      80                                              *:3306                   *:*     users:(("mariadbd",pid=3964,fd=16))
```
```
[matastral@dbtp5linux ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[matastral@dbtp5linux ~]$ sudo firewall-cmd --reload
success
```

🌞 **Processus liés à MariaDB**

```
[matastral@dbtp5linux ~]$ ps -ef | grep mariadb
mysql       3964       1  0 22:31 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
```

Et enfin la partie 3 --->[Partie 3](./Partie3.md)