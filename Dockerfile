FROM docker.io/ubuntu:22.04

ARG ANSIBLE_VERSION=2.10
ARG ANSIBLE_TOWER_CLI_VERSION=3.3.9
ARG VAULT_VERSION=1.6.3
ARG CINC_WORKSTATION_VERSION=23
ARG CINC_WORKSTATION_CHANNEL=stable
ARG CUCUMBER_VERSION=5.0.0

ENV ANSIBLE_TOWER_CLI_VERSION=${ANSIBLE_TOWER_CLI_VERSION}
ENV ANSIBLE_VERSION=${ANSIBLE_VERSION}
ENV VAULT_VERSION=${VAULT_VERSION}
ENV CINC_WORKSTATION_VERSION=${CINC_WORKSTATION_VERSION}
ENV CINC_WORKSTATION_CHANNEL=${CINC_WORKSTATION_CHANNEL}
ENV CUCUMBER_VERSION=${CUCUMBER_VERSION}

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update \
    && apt-get install -y curl unzip python3 git openssh-client python3-pip

RUN python3 -m pip install ansible==${ANSIBLE_VERSION} \
    && python3 -m pip install ansible-tower-cli==${ANSIBLE_TOWER_CLI_VERSION} \
    && python3 -m pip install yamllint ansible-lint

RUN curl -o /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
    && unzip -d /usr/local/bin /tmp/vault.zip \
    && rm -f /tmp/vault.zip

RUN curl -L https://omnitruck.cinc.sh/install.sh | bash -s -- -P cinc-workstation -v ${CINC_WORKSTATION_VERSION} -c ${CINC_WORKSTATION_CHANNEL} \
    && CHEF_LICENSE="accept-no-persist" chef exec gem install cucumber --version=${CUCUMBER_VERSION}

RUN curl -s https://releases.jfrog.io/artifactory/jfrog-gpg-public/jfrog_public_gpg.key | apt-key add - \
    && echo "deb https://releases.jfrog.io/artifactory/jfrog-debs xenial contrib" | tee -a /etc/apt/sources.list \
    && apt update \
    && apt install -y jfrog-cli-v2-jf

RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD [ "/bin/bash" ]
