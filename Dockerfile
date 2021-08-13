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
    curl

# Install extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql mbstring exif pcntl bcmath gd && docker-php-ext-enable pdo_mysql
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

# Copy existing application directory permissions
COPY --chown=www:www . /var/www/html/recyminer-store/

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 8000
CMD ["php-fpm"]
