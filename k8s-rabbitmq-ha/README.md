# RabbitMQ HA Deployment Guide
This is the step-by-step instructions of how to setup the RabbitMQ HA on AliCloud, it includes the steps of
- Preparing docker image (Optional)
- NAS setup for the RabbitMQ Persistence
- Switching to the designated Kubernetes namespace (Optional)
- Creating Kubernetes secret for pulling custom Docker image from private repository
- Using yaml file to deploy the RabbitMQ Cluster
- Performing testing

### Prerequisites
- Clone this repo by executing the shell command below:
```sh
git clone git@github.managed-from.net:IBMChinaPlayground/PoC2.git
```
- Docker image available on the Private Registry of AliCloud, in this deployment we're using the image we built on `registry.cn-qingdao.aliyuncs.com/gen4/rabbitmq-ha:latest`. You can build your own docker image from stretch by using this [Dockerfile](docker/Dockerfile) and push the image on to your registry, please refer [this guide](docker/README.md)
- Please [setup NAS](https://help.aliyun.com/document_detail/27526.html) and get the ```mount URL``` (refer [this link](https://help.aliyun.com/document_detail/60431.html)) and put it in [deployment.yaml](deployment.yaml) where it declares the mount URL of the NAS Server, e.g. see code below under #@TODO
```yaml
containers:
  - name: alicloud-nas-controller
    image: registry.cn-hangzhou.aliyuncs.com/acs/alicloud-nas-controller:v3.1.0-k8s1.11
    volumeMounts:
    - mountPath: /persistentvolumes
      name: nfs-client-root
    env:
      - name: PROVISIONER_NAME
        value: alicloud/nas
      - name: NFS_SERVER
        # @TODO: Please update your mount URL of NAS
        value: xxxxxxxxxx-xxxxx.cn-beijing.nas.aliyuncs.com 
      - name: NFS_PATH
        value: /
volumes:
  - name: nfs-client-root
    nfs:
      # @TODO: Please update your mount URL of NAS
      server: xxxxxxxxxx-xxxxx.cn-beijing.nas.aliyuncs.com
      path: /
```
- **Update the ingress hostname**, the format of the URL is: `your_rabbitmq_management_ui_name.your_k8s_instance_name.your_region_name.alicontainer.com`. e.g. `rabbitmq-portal.cb63acdf806e5464a88157679edf29697.cn-beijing.alicontainer.com`. If you don't want to expose it, please comment that Ingress section out. e.g. see code below under # @TODO
```yaml
kind: Ingress
apiVersion: extensions/v1beta1
metadata:
  namespace: test-compose
  name: rabbitmq-ha-management
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    # @TODO, change hostname prefix and keep the domain from AliCloud (your_rabbitmq_management_ui_name.your_k8s_instance_name.your_region_name.alicontainer.com)
    # e.g. rabbitmq-portal.cb63acdf806e5464a88157679edf29697.cn-beijing.alicontainer.com
    - host: >-
        your_rabbitmq_management_ui_name.your_k8s_instance_name.your_region_name.alicontainer.com
      http:
        paths:
          - backend:
              serviceName: rabbitmq-ha-discovery
              servicePort: 15672
            path: /
```
- Create ```test-compose``` namespace if you don't have it by executing the shell command below:
```sh
kubectl create namespace test-compose
```
- Optionally, switch to namespace of ```test-compose``` by executing the shell command below:

```sh
kubectl config set-context $(kubectl config current-context) --namespace=test-compose
```

- Create secret for the Docker image deployment, assume we're using the Container Registry of Qingdao region, and naming it as `registry-qingdao` (this name is written in the `deployment.yaml`, so if you want to change it, please change the name from the yaml file also). If you're using the **sub-account**, please change the `your_full_username` to **sub-account-name@main-account-id**, then execute the shell command below:
```sh
kubectl create secret docker-registry registry-qingdao --docker-server=registry.cn-qingdao.aliyuncs.com --docker-username=your_full_username --docker-password=your_password -n test-compose
```

### Deployment of RabbitMQ HA Cluster
- Run shell script by using the AliCloud main account (**Subaccount does not work, because the subaccount does not have the access of creating the Role, Rolebinding and ServiceAccount**): 
```sh
kubectl create -f deployment.yaml
```

### Test
- Please manually create the LoadBalancer in the Kubernetes Cluster console and use the [jMeter project](test/jmeter-project) to verify the RabbitMQ
- Whitelist yourself in case you have enabled the network policy on the LoadBalancer you're testing agaist
- Test Preparation
  - [Download](https://jmeter.apache.org/download_jmeter.cgi) & install jMeter 5.0
  - Copy the lib into your jMeter installation directory, it includes the jMeter extension and AMQP client library, they allow you to create the AMQP Publisher and Consumer in the jMeter Project
  - You may refer the [jMeter project file](test/jmeter-project/rabbitmq-ha.jmx) and change the host names from both of AMQP Publisher and Consumer under `Connection` section