#!/bin/bash
set -x

minikube start \
    --kubernetes-version=v1.28.3 \
    --cpus=4 \
    --memory=8192 \
    --disk-size=30g

minikube addons enable ingress

chmod +x ./deploy-yas-configuration.sh
chmod +x ./setup-keycloak.sh
chmod +x ./setup-redis.sh
chmod +x ./setup-cluster.sh
chmod +x ./setup-argocd.sh
chmod +x ./deploy-yas-application.sh

# ./deyploy-yas-configuration.sh
# ./setup-keycloak.sh
# ./setup-redis.sh
# ./setup-cluster.sh
./setup-argocd.sh
# ./deploy-yas-application.sh