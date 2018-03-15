#!/usr/bin/env bash
set -e
until pg_isready --host=db; do
    echo "$(date) - waiting for postgres...on db"
    sleep 1
done

exec /entrypoint.sh "$@"
