
# ODOO + Github Action

- This repository is set up for  externally triggered CI/CD - by [odoo-cicd-executor](https://github.com/xmars4/odoo-cicd-executor) repo.
- Contribution workflow: through Pull Request

## Config

1. Build and publish custom Odoo image

    Follow the instruction in the file [.build/README.md](.build/README.md)

1. On the newly created repo, go to *Settings -> Security -> Secrets and variables -> Actions*, add the following data:

    *Repository secrets:*
     - **DISPATCH_WORKFLOW_PAT**: personal access token that have permisison *repo: Full control of private repositories* of GitHub user *xmars4*

1. Setup executor info

    Follow the instruction in the file [odoo-cicd-executor/README.md](https://github.com/xmars4/odoo-cicd-executor/blob/production/README.md)

1. Deploy

    Follow the instruction in the file [.deploy/README.md](.deploy/README.md)
....
