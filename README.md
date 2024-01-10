# Is it Observable
<p align="center"><img src="/image/logo.png" width="40%" alt="Is It observable Logo" /></p>

## Episode : Apache Skywalking
This repository contains the files utilized during the tutorial presented in the dedicated IsItObservable episode related to the episode What is Apache Skywalking.
<p align="center"><img src="/image/skywalking.png" width="40%" alt="Skywalking Logo" /></p>

this tutorial will also utilize the SkyWalking with:
* the OpenTelemetry Demo
* Hipster-shop


## Prerequisite
The following tools need to be install on your machine :
- jq
- kubectl
- git
- gcloud ( if you are using GKE)
- Helm


### 1.Create a Google Cloud Platform Project
```shell
PROJECT_ID="<your-project-id>"
gcloud services enable container.googleapis.com --project ${PROJECT_ID}
gcloud services enable monitoring.googleapis.com \
cloudtrace.googleapis.com \
clouddebugger.googleapis.com \
cloudprofiler.googleapis.com \
--project ${PROJECT_ID}
```
### 2.Create a GKE cluster
```shell
ZONE=europe-west3-a
NAME=isitobservable-skywalking
gcloud container clusters create ${NAME} --zone=${ZONE} --machine-type=e2-standard-4 --num-nodes=2
```

## Getting started

### Istio

1. Download Istioctl
```shell
curl -L https://istio.io/downloadIstio | sh -
```
This command download the latest version of istio ( in our case istio 1.18.2) compatible with our operating system.
2. Add istioctl to you PATH
```shell
cd istio-1.20.1
```
this directory contains samples with addons . We will refer to it later.
```shell
export PATH=$PWD/bin:$PATH
```

### Clone Github repo
```shell
git clone https://github.com/isItObservable/apache-skywalking
cd apache-skywalking
```



### Deploy most of the components
The application will deploy the entire environment:
```shell
chmod 777 deployment.sh
./deployment.sh   
```
