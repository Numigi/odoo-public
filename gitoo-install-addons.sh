#!/usr/bin/env bash

destination_folder=.extra-addons
if [[ -d "$destination_folder" ]]
  then
    echo "Deleting folder ${destination_folder} (require sudo rights)"
    sudo rm -rf ${destination_folder}
fi

docker-compose run --rm gitoo install-all --lang fr --destination /mnt/extra-addons --conf_file gitoo-addons.yml
