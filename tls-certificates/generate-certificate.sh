 #!/usr/bin/env bash

SSL_DIR="./ssl"

read -p "Who is the issuer [China AFT]:" SSL_CERT_ISSUER
read -p "Please provide the full domain URL [example.com]: " SSL_DOMAIN
read -p "Who is the user? [Car Owner]:" SSL_CERT_USER

SSL_CERT_ISSUER=${SSL_CERT_ISSUER:-"China AFT"}
SSL_DOMAIN=${SSL_DOMAIN:-"example.com"}
SSL_CERT_USER=${SSL_CERT_USER:-"Car Owner"}

SSL_CERT_ROOT="/C=CN/ST=Liaoning/L=Dalian/O=IBM/CN=$SSL_CERT_ISSUER"
SSL_CERT_CLIENT="/C=CN/ST=Liaoning/L=Dalian/O=IBM/CN=$SSL_CERT_USER"
SSL_CERT_SERVER="/C=CN/ST=Liaoning/L=Dalian/O=IBM/CN=$SSL_DOMAIN"

rm -rf "$SSL_DIR"
mkdir -p "$SSL_DIR"

openssl genrsa -des3 -out "$SSL_DIR/ca.key" 4096
openssl req -new -x509 -days 365 -key "$SSL_DIR/ca.key" -out "$SSL_DIR/ca.crt" -subj "$SSL_CERT_ROOT"
openssl genrsa -out "$SSL_DIR/client.key" 4096
openssl req -new -key "$SSL_DIR/client.key" -out "$SSL_DIR/client.csr" -subj "$SSL_CERT_CLIENT"
openssl x509 -req -days 365 -in "$SSL_DIR/client.csr" -CA "$SSL_DIR/ca.crt" -CAkey "$SSL_DIR/ca.key" -set_serial 1000 -out "$SSL_DIR/client.crt"
openssl genrsa -out "$SSL_DIR/server.key" 4096
openssl req -new -key "$SSL_DIR/server.key" -out "$SSL_DIR/server.csr" -subj "$SSL_CERT_SERVER"
openssl x509 -req -days 365 -in "$SSL_DIR/server.csr" -CA "$SSL_DIR/ca.crt" -CAkey "$SSL_DIR/ca.key" -set_serial 1001 -out "$SSL_DIR/server.crt"
openssl pkcs12 -export -clcerts -in "$SSL_DIR/client.crt" -inkey "$SSL_DIR/client.key" -out "$SSL_DIR/client.p12"

cat "$SSL_DIR/server.crt" "$SSL_DIR/client.crt" "$SSL_DIR/ca.crt" > "$SSL_DIR/chain.crt"
