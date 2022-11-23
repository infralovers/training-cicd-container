ARG VAULT_VERSION=1.6.3
FROM docker.io/hashicorp/vault:${VAULT_VERSION} as vault

FROM docker.io/ubuntu:22.04

ARG ANSIBLE_VERSION=2.10.3
ARG ANSIBLE_TOWER_CLI_VERSION=3.3.9
ARG CINC_WORKSTATION_VERSION=22
ARG CINC_WORKSTATION_CHANNEL=unstable
ARG CUCUMBER_VERSION=5.0.0

ENV ANSIBLE_TOWER_CLI_VERSION=${ANSIBLE_TOWER_CLI_VERSION}
ENV ANSIBLE_VERSION=${ANSIBLE_VERSION}
ENV VAULT_VERSION=${VAULT_VERSION}
ENV CINC_WORKSTATION_VERSION=${CINC_WORKSTATION_VERSION}
ENV CINC_WORKSTATION_CHANNEL=${CINC_WORKSTATION_CHANNEL}
ENV CUCUMBER_VERSION=${CUCUMBER_VERSION}

COPY --from=vault /bin/vault /usr/local/bin/

RUN apt-get update -qq \
    && apt-get install -y curl python3 python3-pip unzip git

RUN python3 -m pip install ansible==${ANSIBLE_VERSION} \
    && python3 -m pip install ansible-tower-cli==${ANSIBLE_TOWER_CLI_VERSION} \
    && python3 -m pip install yamllint ansible-lint

RUN curl -L https://omnitruck.cinc.sh/install.sh | bash -s -- -P cinc-workstation -v ${CINC_WORKSTATION_VERSION} \
    && CHEF_LICENSE="accept-no-persist" chef exec gem install cucumber --version=${CUCUMBER_VERSION}

RUN curl -L https://releases.jfrog.io/artifactory/jfrog-gpg-public/jfrog_public_gpg.key | apt-key add - \
    && echo "deb https://releases.jfrog.io/artifactory/jfrog-debs xenial contrib" | tee -a /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y jfrog-cli-v2-jf

RUN apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/*

CMD [ "/bin/bash" ]
