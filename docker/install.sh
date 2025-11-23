# if [ -z "$APP_KEY" ]; then
#   php artisan key:generate --force
# fi
php artisan migrate --force # --seed
php artisan octane:install --server=frankenphp
php artisan storage:link
php artisan optimize:clear
php artisan optimize