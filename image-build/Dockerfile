FROM nginx:1.25.2-alpine
ENV VAULT_ADDR=http://swarm1.home.arpa:8200
RUN apk update && apk add --no-cache --update ca-certificates bash jq curl && rm -rf /var/cache/apk*
RUN curl -X 'GET' \
  "${VAULT_ADDR}/v1/pki_int/ca/pem" \
  -H 'accept: application/json' \
  -o /usr/local/share/ca-certificates/home.arpa.intermediate.crt
RUN curl -X 'GET' \
  "${VAULT_ADDR}/v1/pki/ca/pem" \
  -H 'accept: application/json' \
  -o /usr/local/share/ca-certificates/home.arpa.root.crt  
RUN update-ca-certificates
COPY get-certificates.sh .
RUN chmod +x get-certificates.sh
RUN mkdir /etc/nginx/tls
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]