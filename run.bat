docker compose up --build --d
docker compose exec openssl-kms bash -l -c "glow /opt/google-kms/Readme.md;$SHELL"