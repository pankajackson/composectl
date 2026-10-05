# Vault

This stack runs a single Vault server with persistent file storage at
`/opt/storage/vault/data`. The API is published on `127.0.0.1:8200` for local
host access; other containers on the Compose network can use `http://vault:8200`.

Start it from the repository root with:

```sh
./composectl up vault
```

Initialize Vault once and securely save every unseal key and the initial root
token from the output:

```sh
docker exec -it vault vault operator init
```

Unseal it by running the following command once for each of the required
unseal keys (the default is three of five):

```sh
docker exec -it vault vault operator unseal
```

Enter a different key each time. Then log in locally with
`VAULT_ADDR=http://127.0.0.1:8200 vault login` and the initial root token. Keep
the unseal keys and root token outside this repository and the server.

This starter listener uses HTTP, so keep the API on localhost or a trusted
private Docker network. Configure TLS before exposing Vault to other hosts or
the internet. Back up the data directory while Vault is safely sealed.
