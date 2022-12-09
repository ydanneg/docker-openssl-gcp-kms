docker-compose up --build --d
docker-compose exec openssl-gcp-kms bash -l -c "glow /opt/google-kms/Readme.md;$SHELL"