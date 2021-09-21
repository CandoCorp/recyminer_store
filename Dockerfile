#ARG PHP_EXTENSIONS="apcu bcmath opcache pcntl pdo_mysql redis zip sockets imagick gd exif mysqli pdo mbstring"
#FROM thecodingmachine/php:7.4-v4-slim-apache as php_base
#ENV TEMPLATE_PHP_INI=production
#COPY --chown=docker:docker . /var/www/html/recyminer_store
#RUN composer install --quiet --optimize-autoloader --no-dev
#FROM node:10 as node_dependencies
#WORKDIR /var/www/html/recyminer_store
#ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false
#COPY --from=php_base /var/www/html/recyminer_store /var/www/html/recyminer_store
#RUN npm set progress=false && \
#    npm config set depth 0 && \
#    npm install && \
#    npm run prod && \
#    rm -rf node_modules
#FROM php_base
#COPY --from=node_dependencies --chown=docker:docker /var/www/html/recyminer_store /var/www/html/recyminer_store

FROM php:7.4-fpm

RUN mkdir recyminer-store
# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/html/recyminer-store/

# Set working directory
WORKDIR /var/www/html/recyminer-store/

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    libzip-dev \
    curl

# Install extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql mbstring exif pcntl bcmath gd zip && docker-php-ext-enable pdo_mysql
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
RUN docker-php-ext-install gd
RUN docker-php-source delete

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www/html/recyminer-store/

RUN /usr/local/bin/composer install

# Copy existing application directory permissions
COPY --chown=www:www . /var/www/html/recyminer-store/

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
