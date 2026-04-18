#!/bin/bash
set -x

# 1. Install
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create namespace argocd

if helm list -n argocd | grep -q argocd; then
  echo "[LOG] ArgoCD aready installed"
else
  helm install argocd argo/argo-cd -n argocd \
    --set server.service.type=NodePort \
    --set applicationSet.enabled=false
fi

kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

echo "[LOG] ArgoCD setup complete"

# 2. Get password
ARGO_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d)

# 
