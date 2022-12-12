FROM debian:bullseye-slim AS libkmsp11
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS="yes"
RUN apt-get update -qqy && apt-get install -qqy curl
WORKDIR /usr/lib
RUN curl -OLs https://github.com/GoogleCloudPlatform/kms-integrations/releases/download/v1.1/libkmsp11-1.1-linux-amd64.tar.gz \
    && tar -xf libkmsp11-1.1-linux-amd64.tar.gz \
    && rm libkmsp11-1.1-linux-amd64.tar.gz

FROM debian:bullseye-slim

ARG WORKDIR=/root/google-kms

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS="yes"
RUN apt-get update -qqy && apt-get install -qqy \
    libengine-pkcs11-openssl \
    curl nano gettext-base \
    && rm -rf /var/lib/apt/lists/*

COPY --from=libkmsp11 /usr/lib/libkmsp11-1.1-linux-amd64 /usr/lib/libkmsp11-1.1-linux-amd64
ENV PKCS11_MODULE_PATH="/usr/lib/libkmsp11-1.1-linux-amd64/libkmsp11.so"

WORKDIR $WORKDIR

VOLUME ["/root/.kms", "$WORKDIR"]