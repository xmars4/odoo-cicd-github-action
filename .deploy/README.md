# Odoo installation using Docker compose

## Prerequisite and Installation

Install docker and docker compose

- [Docker](https://docs.docker.com/engine/install/)

- [Docker compose plugin](https://docs.docker.com/compose/install/linux/)

- [Manage Docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/)

## Running Odoo

1. Clone the newly created repo to server

1. Create a config file named **odoo.conf** in folder **[etc/](etc/)**\
you can reference to the [sample file](etc/odoo.conf.sample)

1. Create a file named **password.txt** in folder **[postgresql/](postgresql/)** to store DB password

1. Running Odoo

    ```shell
    cd .deploy
    docker compose up -d
    ```

1. DONE, your Odoo instance will running on [http://localhost:8069](http://localhost:18069)

1. _(Optionally)_ Setup log rotate (on host machine)

    ```shell
    cd $ODOO_DOCKER_PATH/.deploy/scripts
    sudo /bin/bash setup-logrotate.sh
    ```

1. _(Optionally)_ If you want add extra command when run odoo

- With this option, you can run abitrary odoo commands
- for instance:

    - Add **_command_** param to **etc/odoo.conf** file

        ```confile
        ...
        command = -i stock -u sale_management
        ```

    - Restart services

        ```shell
        docker compose restart
        ```
