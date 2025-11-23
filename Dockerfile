# ------------------------
# 1. Base FrankenPHP image
# ------------------------
FROM dunglas/frankenphp AS base

# Install system dependencies & PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    # bash \
    zip unzip git \
    # curl \
    build-essential \
    libpq-dev \
    # libbrotli-dev \
    # libzstd-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    netcat-openbsd \
    pkg-config \
    # libcurl4-openssl-dev \
    libpng-dev \
    libxslt-dev \
    libsodium-dev \
    libjpeg-dev

WORKDIR /app

RUN docker-php-ext-install pdo_pgsql opcache mbstring zip bcmath intl pcntl gd exif sodium xsl

# ------------------------
# 2. Composer dependencies
# ------------------------
FROM base AS vendor

# Install composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy only composer files for caching
COPY composer.json composer.lock ./

RUN composer install --no-dev --no-scripts --no-progress --no-interaction --prefer-dist

# ------------------------
# 3. Final runtime
# ------------------------
FROM base AS app

# Copy composer deps from vendor stage
COPY --from=vendor /app/vendor ./vendor

# Copy Laravel app source
COPY . .

RUN cp .env.example .env

# Copy custom php.ini
COPY ./docker/php/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY ./docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Set permissions for Laravel storage & bootstrap
RUN chown -R www-data:www-data storage bootstrap/cache public
RUN chmod -R 775 storage bootstrap/cache

COPY ./docker/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY ./docker/install.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/install.sh

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php", "artisan", "octane:start", "--host=localhost", "--https", "--http-redirect", "--port=443", "--admin-port=2019"]