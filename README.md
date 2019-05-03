# odoo-public

Patches and fixes can be found in [numigi/odoo repo](https://github.com/Numigi/odoo)

## extended_entrypoint.sh

Extension of the intial entrypoint bash script to improve interaction with the database server.
When the database server is part of the docker-compose stack, we need to wait for the 
database server to be ready before to start the odoo server.

That is the purpose of the script.

### usage
When you launch the odoo server, you see the message  `waiting for postgres...on db`.

The line after displays the status: `no response` or `accepting connections`.

#### Variables
* WAIT_FOR_DB_HOST: to enable or disable the wait. Default: true. (disabled on any other value).

_The variable is useful to manage the case of hosted database server that we don't want to wait._

* DB_HOST: name of service that hosts to wait for. Default: db.

_Change the name of the service of the postgres server is different._