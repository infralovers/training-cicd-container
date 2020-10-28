FROM centos:8

RUN dnf install -y curl unzip

RUN dnf install -y epel-release \
    && dnf install -y ansible \
    && pip3 install ansible-tower-cli

RUN curl -o /tmp/vault.zip https://releases.hashicorp.com/vault/1.5.5/vault_1.5.5_linux_amd64.zip \
    && unzip -d /usr/local/bin /tmp/vault.zip

RUN curl -o /tmp/cinc-install.sh https://omnitruck.cinc.sh/install.sh \
    && chmod 0700 /tmp/cinc-install.sh \
    && /tmp/cinc-install.sh \
    && rm -f /tmp/cinc-install.sh

CMD [ "/bin/bash" ]