#!/bin/bash
set -x

# 1. Install
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl get ns argocd >/dev/null 2>&1 || kubectl create ns argocd

if helm status argocd -n argocd >/dev/null 2>&1; then
  echo "[LOG] ArgoCD aready installed"
else
  helm install argocd argo/argo-cd -n argocd \
    --set server.service.type=NodePort \
    --set applicationSet.enabled=false
fi

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

echo "[LOG] ArgoCD setup complete"

# 2. Get password
ARGO_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d)

echo "Username: admin"
echo "Password: $ARGO_PASSWORD"

# 3. Create namespace
kubectl get ns yas-dev >/dev/null 2>&1 || kubectl create ns yas-dev
kubectl get ns yas-staging >/dev/null 2>&1 || kubectl create ns yas-staging

# 4. Show UI
MINIKUBE_IP=$(minikube ip)
NODE_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath="{.spec.ports[0].nodePort}")

echo "Access ArgoCD UI at: https://$MINIKUBE_IP:$NODE_PORT"

