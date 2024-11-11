#!/bin/sh

####################################
#
#   Instalação via cli do moodle local
#   
#   Automatização do levantamento do ambiente
#
#   Developed By: Erick Bernardo
#
####################################
#
#  Motivação:
#    
# Ao instalar o Moodle via arquivo PHP pela CLI, você pode automatizar o processo de instalação usando um script,
# o que pode economizar tempo e minimizar a possibilidade de erros humanos.
# Além disso, a instalação via CLI oferece mais opções de configuração avançada que podem ser definidas através de parâmetros de linha de comando,
# o que permite personalizar a instalação com mais precisão.
#
#
# https://github.com/moodle/moodle/blob/master/admin/cli/install_database.php
#
#
#Options: (Documentação oficial)
#--lang=CODE           Installation and default site language. Default is en.
#--adminuser=USERNAME  Username for the moodle admin account. Default is admin.
#--adminpass=PASSWORD  Password for the moodle admin account.
#--adminemail=STRING   Email address for the moodle admin account.
#--agree-license       Indicates agreement with software license.
#--fullname=STRING     Name of the site
#--shortname=STRING    Name of the site
#--summary=STRING      The summary to be displayed on the front page
#-h, --help            Print out this help

# Default 
LANG="pt_br"
FULLNAME="modelo-moodle"
SHORTNAME="template"
SUMMARY="Ambiente de modelo para futuras instancias."
ADMINUSER="admin"
ADMINPASS="123456"
ADMINEMAIL="admin@admin.com"
DBHOST="mysql"
DBPORT="3306"

#
# Instalando pacote necessario para configuracao (Suporte somente para alpine)
#
if ! apk info netcat-openbsd > /dev/null 2>&1; then
    echo "O pacote netcat-openbsd não está instalado!"
		echo "Instalando o pacote 'netcat-openbsd'..."
    # Instala o pacote netcat-openbsd
    apk add netcat-openbsd
fi

while true; do
  if nc -zv $DBHOST $DBPORT &> /dev/null; then
    echo "Conexao com o MySQL estabelecida."
    break
  fi
	echo "Aguardando mysql estar disponível para conexão..."
  sleep 1
done

#Permissão de execução para o install_database.php
echo "Dando permissão de execução do install_database..."
chmod +x /var/www/localhost/htdocs/ava/admin/cli/install_database.php

#Instalação do database moodle
echo "Instalando banco de dados local do moodle:"
/usr/bin/php82 /var/www/localhost/htdocs/ava/admin/cli/install_database.php --lang=$LANG --agree-license --fullname=$FULLNAME --shortname=$SHORTNAME --summary=$SUMARRY --adminuser=$ADMINUSER --adminpass=$ADMINPASS --adminemail=$ADMINEMAIL

#Permissão de execução para o purge_caches.php
chmod +x /var/www/localhost/htdocs/ava/admin/cli/purge_caches.php

echo "Executando limpeza de caches..."
#Limpando os caches
/usr/bin/php82 /var/www/localhost/htdocs/ava/admin/cli/purge_caches.php --muc --theme --lang --js --filter
