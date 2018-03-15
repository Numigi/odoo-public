#!/usr/bin/env bash
odoo --db_host=db -r odoo -w odoo -d odoo -i base --stop-after-init --test-enable --workers 0
