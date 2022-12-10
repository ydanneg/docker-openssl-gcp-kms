FROM ubuntu:22.04
WORKDIR /opt/google-kms

RUN apt-get update && apt-get install -y \
    libengine-pkcs11-openssl \
    wget \
    nano \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/GoogleCloudPlatform/kms-integrations/releases/download/v1.1/libkmsp11-1.1-linux-amd64.tar.gz && \
    tar -xf libkmsp11-1.1-linux-amd64.tar.gz && \
    rm libkmsp11-1.1-linux-amd64.tar.gz

ENV PKCS11_MODULE_PATH="/opt/google-kms/libkmsp11-1.1-linux-amd64/libkmsp11.so"

WORKDIR /root/google-kms

ENTRYPOINT ["/bin/bash", "-c", "-l"]
CMD ["echo need help?"]