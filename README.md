# PKCE OAuth2 flow with public client in Bash

Just a simple bash script that can be used to redeem a access-token using a public OAuth2 client with PKCE

## Installation

Copy `oauth2.sh` into /usr/bin folder or any path with executables and make it executable.

e.g Termux on Android:
```bash
cp oauth2.sh /data/data/com.termux/files/usr/bin/oauth2
chmod +x /data/data/com.termux/files/usr/bin/oauth2
```

## Using it with ssh

The intention is to use this with sshpass to allow a neat integration with oauth2 pam modules.
This can be done be simply adding this function into your shell of your choose profile configuration.

```bash
function sshoauth2() {
    sshpass -p $(oauth2 <CLIENT_ID> <AUTHORIZATION_URL> <TOKEN_ENDPOINT>) ssh $1
}
```

Then the following command can be executed in the terminal:
```bash
sshoauth2 ssh user@host
```
