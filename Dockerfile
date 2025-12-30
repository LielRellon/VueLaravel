FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    git unzip curl \
    libpng-dev libonig-dev libxml2-dev \
    libzip-dev zip \
    && docker-php-ext-install pdo_mysql mbstring zip

# Install Node properly
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install --no-dev --optimize-autoloader
RUN npm install && npm run build

CMD ["php-fpm"]