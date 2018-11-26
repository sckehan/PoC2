# RabbitMQ Docker Image
This is the step-by-step instructions of how to build the Docker image locally and push it to the AliCloud Container Registry, it includes the steps of
- Building docker image locally on your machine
- Push on to the AliCloud Container Registry

### Prerequisites
- Have the Docker Engine running on your local machine
- Verify if it works by executing the shell command `docker images`, if you see the output, your engine works properly
```sh
  EPOSITORY    TAG    IMAGE ID    CREATED    SIZE
```

### Build Docker image
- Replace `[tag]` with the tag you need, and execute shell command to build the docker image:
```sh
docker build . -t registry.cn-qingdao.aliyuncs.com/gen4/rabbitmq-ha:[tag]
```
- Verify the Docker image built by executing the shell command below, you should see the image built in the list with the tag:
```sh
docker images
```

### Upload Docker image
- Log in to Alibaba Cloud Docker Registry, if you're using the **sub-account**, please change the `your_full_username` to **sub-account-name@main-account-id**, enter the password then you should see `Login Succeeded`.
```sh
docker login --username=your_full_username registry.cn-qingdao.aliyuncs.com
```
- Push the docker image on to the private repository of AliCloud Container Registry Service, replace `[tag]` with the tag you set, then execute the shell command:
```sh
docker push registry.cn-qingdao.aliyuncs.com/gen4/rabbitmq-ha:[tag]
```