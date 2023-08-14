# php7-fpm/Dockerfile
FROM php:8-fpm
COPY php.ini /usr/local/etc/php/

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    wget \
    zlib1g-dev \
    libicu-dev \
    g++ \
    nodejs \
    npm

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

# Install Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash
RUN mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

# Set timezone
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Type docker-php-ext-install to see available extensions
RUN docker-php-ext-configure intl
RUN docker-php-ext-install pdo pdo_mysql intl opcache
RUN pecl install pcov
RUN docker-php-ext-enable pcov

# Install NodeJS
RUN npm install -g n
RUN n stable

# Upgrade npm
RUN npm install -g npm

WORKDIR /var/www/symfony
