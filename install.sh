#!/bin/sh
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 {Azure ACR host} {ACR username} {ACR password}" >&2
  exit 1
fi

kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml

echo "Looking for namespace..."
if ! kubectl get namespaces -o json | jq -r ".items[].metadata.name" | grep build-example; then

    kubectl create namespace build-example \
    --dry-run=client \
    -o yaml | kubectl apply -f -
else
  echo "Namespace build-example allready esists, skipping creation"
fi

kubectl create secret -n build-example docker-registry basic-user-pass \
  --docker-server=$1 \
  --docker-username=$2 \
  --docker-password=$3 \
  --dry-run=client \
  -o yaml | kubectl apply -f -

#kubectl create secret generic basic-user-pass --type="kubernetes.io/basic-auth" -n build-example \
#  --from-literal=username=$2 \
#  --from-literal=password=$3 \
#  --dry-run=client \
#  -o yaml | kubectl apply -f -

#kubectl annotate --overwrite -n build-example secret basic-user-pass "tekton.dev/docker-0"=$1

kubectl apply -f tutorial-service.yaml -n build-example 
kubectl apply -f skaffold-git.yaml -n build-example
kubectl apply -f skaffold-image-leeroy-web.yaml -n build-example 
kubectl apply -f build-docker-image-from-git-source.yaml -n build-example 
kubectl apply -f build-docker-image-from-git-source-task-run.yaml -n build-example 

kubectl get serviceaccount,task,taskrun,pipelineresource,pods,secret -n build-example