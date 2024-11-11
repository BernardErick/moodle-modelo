FROM alpine:3.18.2

RUN apk update && apk add --no-cache \
    apache2 openrc \
    php82 \
    php82-apache2 \
    php82-cli \
    php82-common \
    php82-ctype \
    php82-curl \
    php82-dom \
    php82-gd \
    php82-iconv \
    php82-intl \
    php82-json \
    php82-mbstring \
    php82-opcache \
    php82-pdo \
    php82-xml \
    php82-zip \
    php82-mysqli \
    php82-session \
    php82-tokenizer \
    php82-fileinfo \
    php82-openssl \
    php82-xmlreader \
    php82-xmlwriter \
    php82-xsl \
    php82-soap \
    php82-sodium \
    php82-exif \
    php82-simplexml \
    php82-pecl-memcached \
    php82-pecl-redis \
    php82-pecl-msgpack \
    php82-pear \
    php82-pecl-yaml \
    php82-dev \
    php82-posix \
    php82-tidy \
    php82-pspell \
    php82-phar \
    php82-odbc \
    php82-bz2 \
    php82-bcmath \
    php82-pecl-igbinary \
    mariadb-client \
    ghostscript \
    dos2unix  \
    icu-data-full \
		unzip

RUN rm -fr /var/www/localhost/htdocs/index.html && \
    mkdir -p /var/moodle_shared/moodledata && \
    mkdir /moodle && \
    chmod -R 777 /var/moodle_shared /tmp

RUN echo '*/1     *       *       *       *       /usr/bin/php82  /var/www/localhost/htdocs/ava/admin/cli/cron.php' >> /etc/crontabs/root

# Fix ErrorLogFormat remoteip: X-Forwarded-For
RUN echo 'ErrorLogFormat "[%{u}t] [%-m:%l] [pid %P] %7F: %E: [client\ %a] [%{X-Forwarded-For}i] %M% ,\ referer\ %{Referer}i"' >> /etc/apache2/httpd.conf

#Remove Indexes FollowSymLinks do apache
RUN sed -i 's/Options Indexes FollowSymLinks/#Options Indexes FollowSymLinks/g' /etc/apache2/httpd.conf
RUN echo "max_input_vars = 5000" >> /etc/php82/php.ini
# Fix php.ini
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 120M/' /etc/php82/php.ini \
    && sed -i 's/post_max_size = 8M/post_max_size = 120M/' /etc/php82/php.ini \
    && sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php82/php.ini \
    && sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT \& ~E_NOTICE/' /etc/php82/php.ini

#Copiando moodle e extraindo
COPY moodle-MOODLE_402_STABLE.zip /moodle
RUN unzip /moodle/moodle-MOODLE_402_STABLE.zip -d /var/www/localhost/htdocs
RUN mv /var/www/localhost/htdocs/moodle-MOODLE_402_STABLE /var/www/localhost/htdocs/moodle

#Copiando startup.sh
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

# Removendo lixo
RUN rm -fr /var/www/localhost/htdocs/moodle/.[!.]* \
   && rm -fr /var/www/localhost/htdocs/moodle/*.js \
   && rm -fr /var/www/localhost/htdocs/moodle/*.json \
   && rm -fr /var/www/localhost/htdocs/moodle/*.txt \
   && rm -fr /var/www/localhost/htdocs/moodle/*.dist \
   && rm -fr /var/www/localhost/htdocs/moodle/*.lock

# Copiando moodle, e renomeando pasta
COPY . /ava
RUN mv /var/www/localhost/htdocs/moodle /var/www/localhost/htdocs/ava

# Copiando as configurações
RUN cp -a /ava/config-dev.php /var/www/localhost/htdocs/ava/config.php

# Config MPM Apache/HTTPD:
RUN sed -i '/<IfModule mpm_prefork_module>/,/<\/IfModule>/ s/    StartServers             5/    StartServers            10/' /etc/apache2/conf.d/mpm.conf \
    && sed -i '/<IfModule mpm_prefork_module>/,/<\/IfModule>/ s/    MinSpareServers          5/    MinSpareServers         10/' /etc/apache2/conf.d/mpm.conf \
    && sed -i '/<IfModule mpm_prefork_module>/,/<\/IfModule>/ s/    MaxSpareServers         10/    MaxSpareServers         20/' /etc/apache2/conf.d/mpm.conf \
    && sed -i '/<IfModule mpm_prefork_module>/,/<\/IfModule>/ s/    MaxRequestWorkers      250/    MaxRequestWorkers       500/' /etc/apache2/conf.d/mpm.conf \
    && sed -i '/<IfModule mpm_prefork_module>/,/<\/IfModule>/ s/    MaxConnectionsPerChild   0/    MaxConnectionsPerChild  2000/' /etc/apache2/conf.d/mpm.conf \
    && sed -i '/<IfModule mpm_prefork_module>/a \    ServerLimit             500' /etc/apache2/conf.d/mpm.conf

#O Apache está com a configuração ServerTokens definida como “OS”, o que acaba
#expondo muitas informações nos cabeçalhos de resposta. Sugerimos definir como “Prod” para
#evitar o envio dessas informações
RUN sed -i 's/ServerTokens OS/ServerTokens Prod/' /etc/apache2/httpd.conf

#O Apache está com a configuração ServerSignature definida como “On”, o que acaba
#expondo muitas informações em páginas de listagem de diretórios, páginas de erro e outras
#páginas geradas pelo servidor.. Sugerimos definir como “Off” para evitar o envio dessas
#informações.
RUN sed -i 's/ServerSignature On/ServerSignature Off/' /etc/apache2/httpd.conf

#Sobre a variável max_input_vars, embora o Moodle sugira um valor mínimo de 5.000
#(nas versões mais recentes é obrigatório), considerando um curso Moodle com 300
#participantes e 20 atividades, algumas operações com o livro de notas já ultrapassariam esse
#limite. Como esse é um limite pensado principalmente em prevenção de ataques DoS, temos
#utilizado com nossos clientes o valor de 100.000 (cem mil, não deve ter o ponto na
#configuração, somente os números).

#Mudando temporariamente pro PHP82
RUN sed -i 's/;max_input_vars = 1000/max_input_vars = 100000/' /etc/php82/php.ini


#Checando todos os diretorios publicos / privados para ficar de acordo com a Verificação de segurança
#Adicionando o Options -Indexes no Directory
RUN sed -i '/<Directory "\/var\/www\/localhost\/htdocs">/{n;s/.*/&\n    Options -Indexes/}' /etc/apache2/httpd.conf
#Adicionando os Directorymatch e Filesmatch
RUN echo -e '<Directorymatch "(^/.*/\.git/|^/.*/\.github/|fixtures|behat)">\n \
    Order deny,allow\n \
    Deny from all\n \
</Directorymatch>\n \
\n \
<Filesmatch "(.stylelintrc|composer.json|composer.lock|upgrade.txt|environment.xml|install.xml|readme_moodle.txt|readme.txt|README.txt|README.md|upgrade.txt|phpunit.xml.dist|.gitattributes|.gitignore)">\n \
    Order deny,allow\n \
    Deny from all\n \
</Filesmatch>' >> /etc/apache2/httpd.conf
# Removendo lixo
RUN rm -fr /ava \
    && rm -fr /var/www/localhost/htdocs/ava/install \
    && rm -fr /var/www/localhost/htdocs/ava/install.php

# Fix start apache server
RUN mkdir /run/openrc/ && touch /run/openrc/softlevel && openrc

#   CMD && mkdir /run/openrc/ && touch /run/openrc/softlevel && openrc \
# Iniciando o container
CMD printf "###CONFIG###\n" && cat /var/www/localhost/htdocs/ava/config.php \
    && /etc/init.d/apache2 start \
    && /startup.sh


