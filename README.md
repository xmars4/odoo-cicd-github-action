
# ODOO + Github Action

This repository is set up for self-triggering CI/CD (GitHub Actions workflow).

## Config

1. Build and publish custom Odoo image

    Follow the instruction in the file [.build/README.md](.build/README.md)

1. Setup GitHub Actions secrets and variables

    On the newly created repo, go to *Settings -> Security -> Secrets and variables -> Actions*, add the following data:
    - *Environment secrets:*
        - **DOCKERHUB_USERNAME**: Docker hub registry username ( for access custom Odoo image)
        - **DOCKERHUB_TOKEN**: Docker hub registry token
        - **SERVER_DB_PASSWORD**: Server database password for the backup process
        - **SERVER_PRIVATE_KEY**: Server private key file for access to the server through SSH or SCP protocol
        - **SSH_PRIVATE_KEY_GITHUB**: Private SSH key to allow access to GitHub
        - **TELEGRAM_CHANNEL_ID**: Telegram channel ID for notifications through the Telegram channel
        - **TELEGRAM_TOKEN**: Telegram BOT token (the BOT added to this TELEGRAM_CHANNEL_ID)

    - *Environment variables:*
        - **DB_IMAGE_TAG**: Postgres image tag name
        - **ODOO_IMAGE_TAG**: Odoo image tag name
        - **SERVER_DEPLOY_PATH**: Server deployment path, the folder containing the docker-compose.yml file
        - **SERVER_HOST**: Server IP address
        - **SERVER_ODOO_DB_NAME**: Odoo database name
        - **SERVER_ODOO_URL**: Odoo URL
        - **SERVER_SSH_PORT**: Server SSH port
        - **SERVER_USER**: Username for SSH connection

1. Deploy

    Follow the instruction in the file [.deploy/README.md](.deploy/README.md)

## Problems & Solutions

1. Sometime we cannot authenticate by ssh

```shell
https://github.com/garygrossgarten/github-action-ssh/issues/20
    at SSH2Stream.Writable.write (node:internal/streams/writable:336:10) {
  level: 'client-authentication'
```

- Solution:

```bash
# gen ssh-key by different algorithm
ssh-keygen -t ecdsa -b 521
```
