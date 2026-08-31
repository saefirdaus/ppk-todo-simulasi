FROM php:8.3-cli

# Build arguments for dynamic user ID and group ID
ARG UID=1000
ARG GID=1000
ARG USER=developer

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    default-mysql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Laravel
RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    opcache

# Copy Composer binary from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user matching host UID/GID
RUN groupadd -g ${GID} ${USER} || true \
    && useradd -u ${UID} -g ${GID} -m -s /bin/bash ${USER} || true \
    && mkdir -p /home/${USER}/.composer \
    && chown -R ${USER}:${USER} /home/${USER}

# Set custom PHP configuration
COPY docker/php/custom.ini /usr/local/etc/php/conf.d/custom.ini

# Set working directory
WORKDIR /var/www

# Switch to non-root user
USER ${USER}

# Expose port for "php artisan serve"
EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
