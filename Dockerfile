FROM docker.io/ubuntu:24.04

ARG ANSIBLE_VERSION=2.10
ARG ANSIBLE_TOWER_CLI_VERSION=3.3.9
ARG VAULT_VERSION=1.6.3
ARG CINC_WORKSTATION_VERSION=24
ARG CINC_WORKSTATION_CHANNEL=stable
ARG CUCUMBER_VERSION=5.0.0

ENV ANSIBLE_TOWER_CLI_VERSION=${ANSIBLE_TOWER_CLI_VERSION}
ENV ANSIBLE_VERSION=${ANSIBLE_VERSION}
ENV VAULT_VERSION=${VAULT_VERSION}
ENV CINC_WORKSTATION_VERSION=${CINC_WORKSTATION_VERSION}
ENV CINC_WORKSTATION_CHANNEL=${CINC_WORKSTATION_CHANNEL}
ENV CUCUMBER_VERSION=${CUCUMBER_VERSION}

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

ENV VIRTUAL_ENV=/opt/ansible-venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN apt-get update \
    && apt-get install -y curl unzip python3 git openssh-client python3-pip python3-virtualenv \
    && virtualenv -p python3 "$VIRTUAL_ENV"

RUN "${VIRTUAL_ENV}/bin/pip3" install ansible==${ANSIBLE_VERSION} \
    && "${VIRTUAL_ENV}/bin/pip3" install ansible-tower-cli==${ANSIBLE_TOWER_CLI_VERSION} \
    && "${VIRTUAL_ENV}/bin/pip3" install yamllint ansible-lint

RUN curl -o /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
    && unzip -d /usr/local/bin /tmp/vault.zip \
    && rm -f /tmp/vault.zip


RUN curl -s  https://releases.jfrog.io/artifactory/api/v2/repositories/jfrog-debs/keyPairs/primary/public | gpg --dearmor -o /usr/share/keyrings/jfrog.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/jfrog.gpg] https://releases.jfrog.io/artifactory/jfrog-debs focal contrib" | tee /etc/apt/sources.list.d/jfrog.list \
    && apt-get update \
    && apt-get install -y jfrog-cli-v2-jf

RUN curl -L https://omnitruck.cinc.sh/install.sh | bash -s -- -P cinc-workstation -v ${CINC_WORKSTATION_VERSION} \
    && CHEF_LICENSE="accept-no-persist" chef exec gem install cucumber --version=${CUCUMBER_VERSION}

RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD [ "/bin/bash" ]
