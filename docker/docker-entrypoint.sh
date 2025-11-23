#!/bin/sh
set -e  # Stop on error

# Configs
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-3306}
REDIS_HOST=${REDIS_HOST:-redis}
REDIS_PORT=${REDIS_PORT:-6379}

# Wait for PostgreSQL
until nc -z "$DB_HOST" "$DB_PORT"; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done
echo "PostgreSQL is ready!"

# Wait for Redis
until nc -z "$REDIS_HOST" "$REDIS_PORT"; do
  echo "Waiting for Redis..."
  sleep 2
done
echo "Redis is ready!"

su -s /bin/sh www-data -c "install.sh"

echo "Starting app..."
exec "$@"