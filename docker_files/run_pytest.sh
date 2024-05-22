#!/usr/bin/env bash
LOG_DIR=${LOG_ODOO:-/var/log/odoo}
TEST_DIR=${1:-/mnt/extra-addons}

mkdir -p $LOG_DIR
chown -R odoo:odoo $LOG_DIR


cd $TEST_DIR

# Run pytest with the specified directories and options
pytest . \
    -v \
    --disable-warnings \
    --cov \
    --cov-branch \
    --cov-config /.coveragerc \
    --cov-report xml \
    --junit-xml=${LOG_DIR}/junit.xml
