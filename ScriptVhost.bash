#!/bin/bash
#Script codé et rédigé par Anthony et Mathieu de l'E2N.
#Ce script sert à faire un vhost.
read -p "Taper -h pour lancer l'aide : " aide
if [ "${aide}" == "-h" ]; then
echo "
Ce script sert à créer un vhost local non sécurisé.


Voici quelques explications sur ce que l'on demande de remplir.

Nom de l'utilisateur = Votre nom d'utilisateur (home/____<= à remplir). Si vous ne remplissez pas le champ, on vous le redemande sinon le script se quitte.
Si vous n'êtes pas sûr de votre nom d'utilisateur faire whoami dans le terminal, vous ne devez pas être connecté en root pour faire cette commande.

Nom du dossier = Nom du dossier où va être stocké votre vhost('/home/utilisateur/___' <= à remplir ou par défaut '/home/utilisateur/www').

Nom du vhost = Nom de votre vhost et qui va aussi être le nom du dossier '/home/utilisateur/dossier ou www/_____'
"
fi
if [ "$(whoami)" != 'root' ]; then
echo "Vous devez lancer le script en root grâce à la commande sudo -s."
exit 1;
fi
read -p "Nom de l'utilisateur (home/____<= à remplir) : " user
if  [ "${user}" == "" ]; then
read -p "Vous n'avez pas entré de nom d'utilisateur : " user
if [ "${user}" == "" ]; then
  echo "Vous n'avez toujours pas rentré de nom d'utilisateur, le script se quitte."
    exit 1;
fi
fi
read -p "Nom du dossier (/home/utilisateur/___ <= à remplir ou par defaut /home/utilisateur/www ) : " folder
if  [ "${folder}" == "" ]; then
read -p "Nom du vhost : " site
if  [ "${site}" == "" ]; then
  echo "Vous n'avez pas donné de nom à votre vhost : "
  read -p 'nom du site : ' site
  if [ "${site}" == "" ]; then
    echo "Vous n'avez toujours pas donné de nom à votre vhost, le script se quitte."
    exit 1;
  fi
fi
mkdir -p /home/$user/www/$site
chown -R $user:$user /home/$user/www/$site
touch /etc/apache2/sites-available/$site.conf
touch /home/$user/www/$site/index.php
chown -R $user /home/$user/www/$site/index.php
echo "<h1>Bienvenue sur $site</h1>" > /home/$user/www/$site/index.php
echo "<VirtualHost *:80>
ServerAdmin webmaster@$site
ServerName www.$site
ServerAlias $site
DocumentRoot /home/$user/www/$site/
<Directory /home/$user/www/$site/>
AllowOverride All
Require all granted
</Directory>
ErrorLog /var/log/apache2/e2n-error.log
LogLevel warn
CustomLog /var/log/apache2/e2n-access.log combined
ServerSignature Off
</VirtualHost>" > /etc/apache2/sites-available/$site.conf
a2ensite $site
service apache2 reload
echo "127.0.0.1 $site" >> /etc/hosts
read -p "Voulez vous redemarrer le service reseau [O/n] : " ok
if [ "${ok}" == "n" ]; then
  exit 1;
fi
service networking restart
echo "Le réseau a été redémarer"
echo "Votre Vhost $site a été initialisé"
exit
else
read -p "Nom du vhost : " site
if  [ "${site}" == "" ]; then
  echo "Vous n'avez donné de nom à votre vhost : "
  read -p 'nom du site : ' site
  if [ "${site}" == "" ]; then
    echo "Vous n'avez toujours pas donné de nom à votre vhost, le script se quitte."
    exit 1;
  fi
fi
mkdir -p /home/$user/$folder/$site
chown -R $user /home/$user/$folder/$site
touch /etc/apache2/sites-available/$site.conf
touch /home/$user/$folder/$site/index.php
echo "<h1>Bienvenue sur $site</h1>" > /home/$user/$folder/$site/index.php
echo "<VirtualHost *:80>
ServerAdmin webmaster@$site
ServerName www.$site
ServerAlias $site
DocumentRoot /home/$user/$folder/$site/
<Directory /home/$user/$folder/$site/>
AllowOverride All
Require all granted
</Directory>
ErrorLog /var/log/apache2/e2n-error.log
LogLevel warn
CustomLog /var/log/apache2/e2n-access.log combined
ServerSignature Off
</VirtualHost>" > /etc/apache2/sites-available/$site.conf
a2ensite $site
service apache2 reload
echo "127.0.0.1 $site" >> /etc/hosts
read -p "Voulez vous redemarrer le service reseau [O/n]" ok
if [ "${ok}" == "n" ]; then
  exit 1;
fi
service networking restart
echo "Le réseau a été redémarer"
echo "Votre vhost $site a été initialisé"
fi
exit 1;
