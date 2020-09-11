#!/usr/bin/env bash

destination_folder=.odoo-source-code
if [[ -d "$destination_folder" ]]
  then
    echo "Deleting folder ${destination_folder} (require sudo rights)"
    sudo rm -rf ${destination_folder}
fi

docker-compose run --rm gitoo install-all --lang fr --destination /mnt/odoo --conf_file gitoo.yml
