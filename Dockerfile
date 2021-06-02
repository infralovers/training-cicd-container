FROM docker.io/centos:8

ARG ANSIBLE_VERSION=2.10
ARG ANSIBLE_TOWER_CLI_VERSION=3.3.9
ARG VAULT_VERSION=1.6.3
ARG CINC_WORKSTATION_VERSION=0.17
ARG CINC_WORKSTATION_CHANNEL=unstable
ARG CUCUMBER_VERSION=5.0.0

ENV ANSIBLE_TOWER_CLI_VERSION=${ANSIBLE_TOWER_CLI_VERSION}
ENV ANSIBLE_VERSION=${ANSIBLE_VERSION}
ENV VAULT_VERSION=${VAULT_VERSION}
ENV CINC_WORKSTATION_VERSION=${CINC_WORKSTATION_VERSION}
ENV CINC_WORKSTATION_CHANNEL=${CINC_WORKSTATION_CHANNEL}
ENV CUCUMBER_VERSION=${CUCUMBER_VERSION}

RUN dnf install -y curl unzip python3 git openssh-clients \
    && python3 -m pip install -U pip

RUN python3 -m pip install ansible==${ANSIBLE_VERSION} \
    && python3 -m pip install ansible-tower-cli==${ANSIBLE_TOWER_CLI_VERSION} \
    && python3 -m pip install yamllint ansible-lint

RUN curl -o /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
    && unzip -d /usr/local/bin /tmp/vault.zip \
    && rm -f /tmp/vault.zip

RUN curl -L https://omnitruck.cinc.sh/install.sh | bash -s -- -P cinc-workstation -v ${CINC_WORKSTATION_VERSION} -c ${CINC_WORKSTATION_CHANNEL}
RUN CHEF_LICENSE="accept-no-persist" chef exec gem install cucumber --version=${CUCUMBER_VERSION}

RUN echo "[jfrog-cli]" > /etc/yum.repos.d/jfrog-cli.repo \
    && echo "name=jfrog-cli" >> /etc/yum.repos.d/jfrog-cli.repo \
    && echo "baseurl=https://releases.jfrog.io/artifactory/jfrog-rpms" >> /etc/yum.repos.d/jfrog-cli.repo \
    && echo "enabled=1" >> jfrog-cli.repo \
    && echo "gpgcheck=0" >> /etc/yum.repos.d/jfrog-cli.repo \
    && dnf install -y jfrog-cli


RUN dnf clean all

CMD [ "/bin/bash" ]
