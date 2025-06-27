# create certificates

mkdir -p ./certs

openssl req -x509 -newkey rsa:4096 -sha256 -days 365 \
  -nodes -keyout ./certs/selfsigned.key \
  -out ./certs/selfsigned.crt \
  -subj "/CN=backend.localhost" \
  -addext "subjectAltName=DNS:backend.localhost,IP:127.0.0.1"
