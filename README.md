
# ODOO + Github Action

1. Build image

- follow instruction in the file [.build/README.md](.build/README.md)

2. Setup CI/CD

- #### TODO : update descript ci/cd here

- Sometime we cannot authenticate by ssh

```
https://github.com/garygrossgarten/github-action-ssh/issues/20
    at SSH2Stream.Writable.write (node:internal/streams/writable:336:10) {
  level: 'client-authentication'
```

- Solution:

```bash
# gen ssh-key by different algorithm
ssh-keygen -t ecdsa -b 521
```

3. Deploy

- follow instruction in the file [.deploy/README.md](.deploy/README.md)
