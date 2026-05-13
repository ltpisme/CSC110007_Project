#!/bin/bash

set +e

echo "📦 Creating namespace argocd..."
kubectl create namespace argocd || true

echo "⚙️ Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting for ArgoCD pods..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "🌐 Exposing ArgoCD UI..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

echo "🔑 Getting initial admin password..."
ARGO_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)

kubectl port-forward svc/argocd-server -n argocd 8080:443 &

echo ""
echo "ArgoCD installed!"
echo "Access UI"
echo "Url: http://localhost:8080"
echo "User: admin"
echo "Password: $ARGO_PASS"

kubectl apply -n argocd -f argocd/dev-app.yml
kubectl apply -n argocd -f argocd/staging-app.yml

kubectl get pods -n argocd
kubectl get applications -n argocd
