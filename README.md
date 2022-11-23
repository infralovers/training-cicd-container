# Dockerfile that provides:

* ansible cli
* ansible-tower cli
* cinc-workstation
* hashicorp vault cli
* cucumber with embedded ruby of cinc


## Multi-Arch Support

Because cinc is not able to be installed on arm64, the container is only available for **linux/amd64**, but support for multiple is already built into github action.

## Availability

[Docker hub](https://hub.docker.com/repository/docker/commandemy/training-cicd/)
[Quay.io](https://quay.io/repository/infralovers/training-cicd) ( upcoming... )