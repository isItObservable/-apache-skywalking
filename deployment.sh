#!/usr/bin/env bash

################################################################################
### Script deploying the Observ-K8s environment
### Parameters:
### Clustern name: name of your k8s cluster
### dttoken: Dynatrace api token with ingest metrics and otlp ingest scope
### dturl : url of your DT tenant wihtout any / at the end for example: https://dedede.live.dynatrace.com
################################################################################


### Pre-flight checks for dependencies
if ! command -v jq >/dev/null 2>&1; then
    echo "Please install jq before continuing"
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "Please install git before continuing"
    exit 1
fi


if ! command -v helm >/dev/null 2>&1; then
    echo "Please install helm before continuing"
    exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
    echo "Please install kubectl before continuing"
    exit 1
fi




#### Deploy the cert-manager
echo "Deploying Cert Manager ( for OpenTelemetry Operator)"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
# Wait for pod webhook started
kubectl wait pod -l app.kubernetes.io/component=webhook -n cert-manager --for=condition=Ready --timeout=2m
# Deploy the opentelemetry operator
sleep 10
echo "Deploying the OpenTelemetry Operator"
kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml


istioctl install -f istio/istio-operator.yaml --skip-confirmation


### get the ip adress of ingress ####
IP=""
while [ -z $IP ]; do
  echo "Waiting for external IP"
  IP=$(kubectl get svc istio-ingressgateway -n istio-system -ojson | jq -j '.status.loadBalancer.ingress[].ip')
  [ -z "$IP" ] && sleep 10
done
echo 'Found external IP: '$IP

### Update the ip of the ip adress for the ingres
#TODO to update this part to create the various Gateway rules
sed -i "s,IP_TO_REPLACE,$IP," istio/istio_gateway.yaml
sed -i "s,IP_TO_REPLACE,$IP," istio/istio_gateway_skywalking.yaml


#### Deploy the Skywalking

export REPO=chart
export SKYWALKING_RELEASE_NAME=skywalking
kubectl create ns skywalking
helm install "${SKYWALKING_RELEASE_NAME}" oci://registry-1.docker.io/apache/skywalking-helm \
  -n "${SKYWALKING_RELEASE_NAME}" \
  --set oap.image.tag=9.5.0 \
  --set oap.storageType=elasticsearch \
  --set ui.image.tag=9.5.0 \
  --set elasticsearch.enabled=true \
  --set oap.dynamicConfig.enabled=true \
  --set oap.envoy.als.enabled=true \
  --set oap.env.SW_ENVOY_METRIC_ALS_HTTP_ANALYSIS=mx-mesh \
  --set oap.env.SW_ENVOY_METRIC_ALS_TCP_ANALYSIS=mx-mesh \
  --set oap.env.SW_QUERY_ZIPKIN=default \
  --set oap.env.SW_AGENT_ANALYZER=default \
  --set oap.env.SW_METER_ANALYZER_ACTIVE_FILES=network-profiling
helm install node-exporter prometheus-community/prometheus-node-exporter
helm install kuebstatemetrics prometheus-community/kube-state-metrics
kubectl apply -f skywalking/event_exporter.yaml -n skywalking
kubectl apply -f skywalking/rover.yaml -n skywalking

# Deploy collector
kubectl apply -f opentelemetry/rbac.yaml
kubectl apply -f opentelemetry/openTelemetry-manifest_debut.yaml

#deploy demo application
kubectl create ns hipster-shop
kubectl label namespace hipster-shop istio-injection=enabled

kubectl apply -f hipstershop/k8s-manifest.yaml -n hipster-shop
#Deploy the ingress rules
kubectl apply -f istio/istio_gateway.yaml



kubectl create ns otel-demo
kubectl label namespace otel-demo istio-injection=enabled
kubectl apply -f openTelemetry/deployment.yaml -n otel-demo


echo "--------------Demo--------------------"
echo "url of the demo: "
echo "hipstershop url: http://hipstershop.$IP.nip.io"
echo "skywalking url: http://skywalking.$IP.nip.io"
echo "========================================================"


