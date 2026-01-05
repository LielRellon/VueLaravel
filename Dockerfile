FROM php:8.4-fpm

WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip \
    libpng-dev libzip-dev libonig-dev \
    && docker-php-ext-install pdo_mysql mbstring zip \
    # Install Node.js
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    # Clean up apt cache to keep image size small
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy ONLY dependency files first to leverage caching
COPY composer.json composer.lock package.json package-lock.json ./

# Install dependencies before copying the rest of the code
RUN composer install --no-dev --no-scripts --no-autoloader
RUN npm install

# Now copy the rest of the application
COPY . .

# Finalize composer and build Vue assets
RUN composer dump-autoload --optimize
RUN npm run build

RUN chown -R www-data:www-data /var/www

EXPOSE 9000
CMD ["php-fpm"]