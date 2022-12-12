# Prerequisites
To run this image you have to provide the following configuration:
* Google service account credentials with permissions to work with KMS (see [Permissions and roles](https://cloud.google.com/kms/docs/reference/permissions-and-roles))
  - Credential JSON file
  - `GOOGLE_APPLICATION_CREDENTIALS` environment variable should point to this file inside container
* PKCS11 KMS library config
  - libengine-pkcs11-openssl library [config file](https://cloud.google.com/kms/docs/reference/pkcs11-openssl#pkcs_11_library_configuration)
  - `KMS_PKCS11_CONFIG` environment variable should point to this file


## Usage
### Docker
Example running configured container
```
docker run \
-v `pwd`/google-credentials.json:/root/.kms/google-credentials.json:ro \
-e GOOGLE_APPLICATION_CREDENTIALS=/root/.kms/google-credentials.json \
-v `pwd`/pkcs11-config.yaml:/root/.kms/pkcs11-config.yaml \
-e KMS_PKCS11_CONFIG=/root/.kms/pkcs11-config.yaml \
-it openssl-gcp-kms:latest \
/bin/bash
```
### Docker compose
Alternately you can run this image using docker-compose:
* ```git clone https://github.com/ydanneg/docker-openssl-gcp-kms.git```
* ```cd docker-openssl-gcp-kms/compose```
* Configure file paths in `.env` file
* `./run.sh`


# References
- https://cloud.google.com/security-key-management
- https://cloud.google.com/kms/docs/reference/pkcs11-openssl
- https://www.openssl.org/docs/man3.0/man1/openssl-ecparam.html
- https://www.openssl.org/docs/man3.0/man1/openssl-req.html
- https://www.openssl.org/docs/man3.0/man1/openssl-x509.html

# Examples
## Generate Test Root CA self-signed Certificate
```shell
openssl req -new -x509 -days 3650 -sha384 -subj \
'/CN=Test Root CA 2023 1/L=Tallinn/C=EE/emailAddress=ydanneg@gmail.com/' \
-addext "keyUsage = keyCertSign, cRLSign" \
-engine pkcs11 -keyform engine -key pkcs11:object=root-2023-1
```


## Generate Test CA (ICA) self-signed CSR
```shell
# generate CSR self-signed with ica key
openssl req -new -sha256 -subj \
'/CN=Test CA 2023 1/L=Tallinn/C=EE/emailAddress=ydanneg@gmail.com/' \
-engine pkcs11 -keyform engine -key pkcs11:object=ica-2023-1 \
-out ica.csr
# compare required pub key was used
openssl req -in ica.csr -noout -pubkey
```
## Issue Test CA (ICA) Certificate from CSR
```shell
openssl x509 -req -in ica.csr -days 1121 -sha384 \
-engine pkcs11 \
-CA root-cert.pem -CAcreateserial -CAkeyform engine -CAkey pkcs11:object=root-2023-1 \
-extensions ca -extfile extensions.cnf \
-out ica.pem
```
## Generate api.ydanneg.com Server SSL and sign it with ICA
```shell

# generate key
openssl ecparam -name secp256r1 -genkey -out server.key

# generate CSR
openssl req -new -sha256 \
-subj "/C=EE/CN=api.ydanneg.com/emailAddress=ydanneg@gmail.com/" \
-addext "subjectAltName = DNS:api.ydanneg.com" \
-key server.key \
-out server.csr

#verify CSR
openssl req -in server.csr -noout -text -verify

# issue certificate from CSR signed by ICA
openssl x509 -req -in server.csr -days 1121 -sha256 \
-engine pkcs11 \
-CA ica.pem -CAkeyform engine -CAcreateserial -CAkey pkcs11:object=ica-2023-1 \
-extensions server -extfile extensions.cnf \
-copy_extensions copy \
-out server.pem

# verify cert
openssl x509 -in server.pem -text -noout

# verify chain
openssl verify -verbose -CAfile <(cat ica.pem root-cert.pem) server.pem 
```

## Generate Client SSL certificate and sign it with ICA
```shell

# generate key
openssl ecparam -name secp256r1 -genkey -out client.key

# generate CSR
openssl req -new -sha256 \
-subj "/CN=this will be ignored anyway/" \
-key client.key \
-out client.csr

#verify CSR
openssl req -in client.csr -noout -text -verify

# issue certificate from CSR signed by ICA
openssl x509 -req -in server.csr -days 1121 -sha256 \
-subj "/CN=ba1c8cb8-3ab6-4987-b793-c49fe3a7bd58/" \
-engine pkcs11 \
-CA ica.pem -CAkeyform engine -CAcreateserial -CAkey pkcs11:object=ica-2023-1 \
-extensions client -extfile extensions.cnf \
-out client.pem

# verify cert
openssl x509 -in client.pem -text -noout

# verify chain
openssl verify -verbose -CAfile <(cat ica.pem root-cert.pem) client.pem 
```
