#!/bin/bash

cp -R /var/www/tmp/. /var/www/html/
chown -R www:www /var/www/html

exec "$@"
