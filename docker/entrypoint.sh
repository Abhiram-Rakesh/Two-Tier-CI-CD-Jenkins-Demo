#!/bin/sh

echo "Waiting for MySQL at $MYSQL_HOST:$MYSQL_PORT..."

while ! nc -z "$MYSQL_HOST" "$MYSQL_PORT"; do
    sleep 2
done

echo "MySQL is up - starting application"

python -c "from app.db.mysql import init_db; init_db()"

exec gunicorn \
    --bind 0.0.0.0:5000 \
    --workers 1 \
    app.app:app
