# TP1 : Are you dead yet ?

# I. Intro

## II. Feu

🌞 **Trouver au moins 4 façons différentes de péter la machine**

1re façon : J'ai supprimé 1 fichier /etc/shadow 
```
[matastral@localhost /]$ sudo rm -rf etc/shadow
```
Il contient tous les mots de passes donc après avoir redémarer la vm, il est impossible de se connecter(si on est pas suffisament calé du moins).

2me façon : J'ai déplacé le dossier /boot/loader dans /root
```
[matastral@localhost /]$ sudo mv /boot/loader /root
```
Le dossier loader permet de charger une "partition". Sans cela, j'arrive sur un terminal mentionnant le terme "grub" et le clavier se met en qwerty.

3me façon : 
