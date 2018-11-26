# PoC2

This repository is the deployment guide of PoC 2.

### Preparation
- Clone this repo by executing the shell command below:
```sh
git clone git@github.managed-from.net:IBMChinaPlayground/PoC2.git
```
- Install `kubectl` and set it up, read the guide from [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/), then configure the cluster credentials, [read it here](https://help.aliyun.com/document_detail/86494.html) about how to get the credetials

- Verify the setup by using the `kubectl`, e.g.
```sh
kubectl get pods
```

### Deployment guide
- [Rabbitmq High Availability](k8s-rabbitmq-ha/)
- [Fluentd](k8s-fluentd/)
- [TLS Certificate for AliCloud Kubernetes Ingress](tls-certificates/)