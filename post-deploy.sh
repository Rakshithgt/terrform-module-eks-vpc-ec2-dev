#!/bin/bash

set -e

CLUSTER_NAME="dev-eks"
REGION="us-east-1"

echo "🔐 Updating kubeconfig for cluster: $CLUSTER_NAME"
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

echo "✅ kubeconfig updated. Verifying connection..."
kubectl get nodes

echo "🌐 Getting LoadBalancer services..."
kubectl get svc -A | grep LoadBalancer

echo "📦 Installed Helm releases:"
helm list -A

echo "📊 Cluster Autoscaler status:"
kubectl get deployment cluster-autoscaler -n kube-system -o wide

echo "📜 Cert-Manager status:"
kubectl get pods -n cert-manager

echo "🧮 Metrics Server status:"
kubectl get deployment metrics-server -n kube-system -o wide

echo "📥 NGINX Ingress status:"
kubectl get svc -n ingress-nginx | grep LoadBalancer

echo "✅ Done!"
