#!/bin/bash
set -e
if [[ -z "$VAULT_ADDR" ]]; then
    echo "VAULT_ADDR env var is not set, cannot unseal"
    exit 1
fi
if [[ -z "$ROLE_ID" ]]; then
    echo "ROLE_ID env var is not set, cannot generate certificate"
    exit 1
fi
if [[ -z "$SECRET_ID_FILE" ]]; then
    echo "SECRET_ID_FILE env var is not set, cannot generate certificate"
    exit 1
fi
SECRET_ID=$(<$SECRET_ID_FILE)
if [[ -z "$SECRET_ID" ]]; then
    echo "SECRET_ID could not be read from $SECRET_ID_FILE"
    exit 1
fi

while true
do
    VAULT_TOKEN=$(curl -k -s --request POST --data '{"role_id":"'"${ROLE_ID}"'","secret_id":"'"${SECRET_ID}"'"}' "${VAULT_ADDR}/v1/auth/approle/login" | jq -r '.auth.client_token')
    curl -s -H "X-Vault-Token: ${VAULT_TOKEN}"  \
        -d '{ "common_name": "*.home.arpa", "ttl":"2678400" }' \
        ${VAULT_ADDR}/v1/pki_int/issue/home-dot-arpa | tee \
        >(jq -r .data.certificate > /etc/nginx/tls/wildcard.crt) \
        >(jq -r .data.private_key > /etc/nginx/tls/wildcard.key) \
        >(jq -r .data.ca_chain[] > /etc/nginx/tls/chain.pem) 1>/dev/null \
        && cat /etc/nginx/tls/wildcard.crt /etc/nginx/tls/chain.pem > /etc/nginx/tls/wildcard-with-chain.pem
    if [ -e /var/run/nginx.pid ]; then
        echo "reloading nginx"
        nginx -s reload
    fi
    sleep 30d
done