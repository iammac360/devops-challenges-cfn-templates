#!/bin/bash

NAMESPACE="${NAMESPACE:-apper}"
CLUSTER_NAME=sarge-eks-tier3-dev
AWS_ACCOUNT_ID=329511059546
AWS_PROFILE=apper_challenge 
REGION=ap-southeast-1
VPC_ID=vpc-03447814bec2259fb

if ! kubectl get ns | grep apper
then
  kubectl create ns apper
else
  echo "Namespace $NAMESPACE already exists"
fi

kubectl config set-context --current --namespace=$NAMESPACE
echo "Namespace is now on $NAMESPACE"

# alb ingress controller
# helm repo add eks https://aws.github.io/eks-charts
# kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
# helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    # --set clusterName=$CLUSTER_NAME \
    # --set serviceAccount.create=false \
    # --set region=$REGION \
    # --set vpcId=$VPC_ID \
    # --set serviceAccount.name=aws-load-balancer-controller \
    # -n kube-system

# nginx ingress controller 
echo "Deploying nginx ingress"
# kubectl apply -f dependencies/nginx-ingress/deploy-tls-termination.yaml
kubectl apply -f dependencies/nginx-ingress/deploy.yaml

# external dns 
echo "Deploying external-dns"
kubectl apply -f dependencies/external-dns/external-dns.yaml

# kubernetes external secrets
echo "Deploying kubernetes-external-secrets"
helm repo add external-secrets https://external-secrets.github.io/kubernetes-external-secrets/
helm install kubernetes-external-secrets external-secrets/kubernetes-external-secrets

# Deploy db secrets
echo "Deploying database secrets"
kubectl apply -f secrets/db-secrets.yaml

# Deploy db service
echo "Deploying database secrets"
kubectl apply -f services/database-service.yaml

# Deploy sarge-express-miniapp
echo "Deploying sarge-express miniapp"
kubectl apply -f services/sarge-express-miniapp-service.yaml
kubectl apply -f deployments/sarge-express-miniapp-deployment.yaml

# Deploy api gateway ingress
echo "Deploying api gateway ingress"
kubectl apply -f ingress/sarge-tier3-gateway-ing.yaml
