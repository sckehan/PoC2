# Fluentd Deployment Guide
This is the step-by-step instructions of how to setup the Fluentd for Elasticsearch on AliCloud, it includes the steps of
- Preparing docker image (Optional)
- Creating Kubernetes secret for pulling custom Docker image from private repository
- Using yaml file to deploy the Fluentd for Elasticsearch
- Verify

### Prerequisites
- Docker image available on the Private Registry of AliCloud, in this deployment we're using the image we built on `registry.cn-qingdao.aliyuncs.com/gen4/fluentd:latest`. You can build your own docker image from stretch by using this [Dockerfile](docker/Dockerfile) and push the image on to your registry, please refer [this guide](docker/README.md)
- You have deployed or provisioned the Elasticsearch from AliCloud, and you're able to get the following information of the existing Elasticsearch instance:
    - Host, e.g. `your_instance.elasticsearch.aliyuncs.com`
    - Scheme, e.g. `http`
    - Port, e.g. `9200`
    - `Username` and `password` for accessing the instance

- Optionally, switch to namespace of ```kube-system``` by executing the shell command below:

```sh
kubectl config set-context $(kubectl config current-context) --namespace=kube-system
```
- Create secret for the Docker image deployment, assume we're using the Container Registry of Qingdao region, and naming it as `registry-qingdao` (this name is written in the `deployment.yaml`, so if you want to change it, please change the name from the yaml file also). If you're using the **sub-account**, please change the `your_full_username` to **sub-account-name@main-account-id**, then execute the shell command below:
```sh
kubectl create secret docker-registry registry-qingdao --docker-server=registry.cn-qingdao.aliyuncs.com --docker-username=your_full_username --docker-password=your_password -n kube-system
```

- Run shell script by using the AliCloud main account (**Subaccount does not work, because the subaccount does not have the access of creating the Role, Rolebinding and ServiceAccount**): 
```sh
kubectl create -f deployment.yaml
```

### Verify
- Go to the Kibana Dashboard and check the indexes and logs