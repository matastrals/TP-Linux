# Partie 1 : Partitionnement du serveur de stockage

🌞 **Partitionner le disque à l'aide de LVM**

```
[matastral@tp4storagelinux ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
```
```
[matastral@tp4storagelinux ~]$ sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created
```
```
[matastral@tp4storagelinux ~]$ sudo lvcreate -l 100%FREE storage -n first_data
  Logical volume "first_data" created.
```

🌞 **Formater la partition**

```
[matastral@tp4storagelinux storage]$ sudo mkfs -t ext4 /dev/storage/first_data
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: 1cbba402-32e8-4b36-9d72-3412886f253f
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

🌞 **Monter la partition**

```
[matastral@tp4storagelinux storage]$ sudo !!
sudo mount /dev/storage/first_data /mnt/first_data1
[matastral@tp4storagelinux storage]$ df -h | grep first
/dev/mapper/storage-first_data  2.0G   24K  1.9G   1% /mnt/first_data1
```
```
[matastral@tp4storagelinux first_data1]$ sudo touch meow
[matastral@tp4storagelinux first_data1]$ ls
lost+found  meow
```
```
[matastral@tp4storagelinux ~]$ sudo cat /etc/fstab | grep first
[sudo] password for matastral:
/dev/storage/first_data /mnt/first_data1 ext4 defaults 0 0
```

Pour la partie 2 ---> [Partie2](./Partie2.md) <---