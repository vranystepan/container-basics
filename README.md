# Containers basics workshop

## PT I

This workshop covers basics with `docker run` and `docker build`.
Example is using simple express application which is built during
the `docker build` process.

### Requirements for Mac OS and Windows

- Docker desktop
- your favorite text editor

### Requirements for Linux-based operating systems

- Docker engine
- your favorite text editor

## PT II

This workshop covers Kubernetes basic resources and some basic
information about the Kubernetes itself.

### Requirements for all platform

- kubectl
    - [linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
    - [Mac OS](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/)
    - [Windows](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- your favorite text editor

Right before the session you need to perform login to the
Kubernetes cluster:

```bash
gcloud container clusters get-credentials workshops-01 --zone europe-central2-a --project revolgy-vaimo-edu
```