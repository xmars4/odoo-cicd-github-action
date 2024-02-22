# Build custom Odoo image

## Prerequisite and Installation

Install docker and docker compose

- [Docker](https://docs.docker.com/engine/install/)

- [Docker compose plugin](https://docs.docker.com/compose/install/linux/)

- [Manage Docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/)

## How to build and publish customized Odoo image on Docker hub

1. Create a new repository using this repository as a template, from branch 'intrinsic'

1. Update required libs to [requirements.txt](requirements.txt) and [Dockerfile](Dockerfile) files before build the image

1. Build and push image to docker registry

    ```shell
    # replace <github username> and <repository name> with correct values
    # e.g: image_tag=xmars/xmars4:odoo-cicd-github-action .
    
    image_tag=xmars/<github username>:<repository name>
    
    cd .build
    docker build --pull -t $image_tag .
    docker login
    docker push $image_tag
    ```

1. Commit change to Github
