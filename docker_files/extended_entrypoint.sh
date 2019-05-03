#!/usr/bin/env bash
set -e

# allow to mentioned if the sleep should be operated.
# the wait is useful when the db server is started at the docker-compose up
# useless for hosted servers.
wait_for_db_host=${WAIT_FOR_DB_HOST:-true}

if [[ "${wait_for_db_host}" = true ]] ; then

    # allow to use a different name for the host of the db than "db"
    # useful when multiple odoo stacks are deployed on the same machine
    db_host=${DB_HOST:-db}

    until pg_isready --host=${db_host}; do
        echo "$(date) - waiting for postgres...on ${db_host}"
        sleep 1
    done
fi

exec /entrypoint.sh "$@"
