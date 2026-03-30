FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    tar \
    skopeo \
    curl

# Syft (CycloneDX support)
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh \
    | sh -s -- -b /usr/local/bin

# ORAS (referrers support)
RUN curl -sSfL https://github.com/oras-project/oras/releases/latest/download/oras_1.1.0_linux_amd64.tar.gz \
    | tar -xz -C /usr/local/bin oras

WORKDIR /app
COPY download.sh /app/download.sh
RUN chmod +x /app/download.sh

ENTRYPOINT ["app/download.sh"]