FROM ubuntu:22.04
WORKDIR /opt/google-kms

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install curl gpg -y
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list
RUN apt update
RUN apt install -y \
    libengine-pkcs11-openssl \
    wget \
    gettext \
    nano \
    glow


RUN wget https://github.com/GoogleCloudPlatform/kms-integrations/releases/download/v1.1/libkmsp11-1.1-linux-amd64.tar.gz
RUN tar -xf libkmsp11-1.1-linux-amd64.tar.gz
RUN rm libkmsp11-1.1-linux-amd64.tar.gz
RUN export PKCS11_MODULE_PATH="/opt/google-kms/libkmsp11-1.1-linux-amd64/libkmsp11.so"
RUN echo 'export PKCS11_MODULE_PATH="/opt/google-kms/libkmsp11-1.1-linux-amd64/libkmsp11.so"' | tee -a /etc/profile

COPY Readme.md ./

WORKDIR /root/google-kms
