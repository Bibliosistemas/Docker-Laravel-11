FROM composer:2 AS composer
########### para laravel 11 : postgresql , composer , gd node y npm 

FROM php:8.3-apache

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apt-get update 
RUN apt-get install -y \
    zip \
    unzip   \
    git \
    libicu-dev  libzip-dev \
    nodejs npm \
	libfreetype-dev \
	libjpeg62-turbo-dev \
	libpng-dev \
    libpq-dev  libxml2 libxml2-dev libxslt1-dev 
RUN docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable   pdo_mysql  
    
RUN docker-php-ext-install pdo_pgsql \
    && docker-php-ext-enable pdo_pgsql 
RUN  docker-php-ext-install intl \
    && docker-php-ext-enable intl
RUN  docker-php-ext-install xsl \
    && docker-php-ext-enable xsl 
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd
   
RUN  docker-php-ext-install zip \
     && docker-php-ext-enable zip 


RUN a2enmod rewrite && \
    sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

EXPOSE 80
ARG UID=1000
ARG GID=1000
ENV USER_NAME=desarrollo
ENV USER_PASS=bsdesarrollo

RUN apt-get install -y sudo 
RUN groupadd -g "${GID}" $USER_NAME \
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" -s "/bin/bash" desarrollo \
  && usermod -aG sudo desarrollo &&  echo "$USER_NAME:$USER_PASS" | chpasswd
RUN echo "$USER_NAME ALL=(ALL:ALL) ALL" > /etc/sudoers

#clean apt
RUN apt-get clean  && rm -rf /var/lib/apt/lists/*  \
CMD ["apache2-foreground"]



