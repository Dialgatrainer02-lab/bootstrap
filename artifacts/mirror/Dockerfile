FROM almalinux:10


# Enable EPEL
RUN dnf -y install epel-release && \
    dnf config-manager --set-enabled crb


# Directory for user-provided repo files
RUN mkdir -p /custom


RUN dnf -y install \
    dnf-plugins-core \
    yum-utils \
    createrepo_c \
    jq \
    tar \
    parallel \
    && dnf clean all

# Install syft (SBOM tool)
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

WORKDIR /sync

COPY reposync.sh /sync/reposync.sh
RUN chmod +x /sync/reposync.sh

CMD ["/sync/reposync.sh"]