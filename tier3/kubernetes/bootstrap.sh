#!/bin/bash

NAMESPACE="${NAMESPACE:-apper}"
CLUSTER_NAME=${CLUSTER_NAME:-sarge-eks-tier3-dev}
AWS_ACCOUNT_ID=329511059546
AWS_PROFILE=${AWS_PROFILE:-apper_challenge} 
REGION=ap-southeast-1
VPC_ID=${VPC_ID:-vpc-03447814bec2259fb}
GENERATED_AUTOSCALER_IAM_ROLE=${GENERATED_AUTOSCALER_IAM_ROLE:-eksctl-sarge-eks-tier3-dev-addon-iamservicea-Role1-1M18UNII4L1XU}

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


# Enable Cluster Autoscaler
echo "Enable Cluster Autoscaler"
eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/SargeEKSClusterAutoScalerPolicy \
  --override-existing-serviceaccounts \
  --profile $AWS_PROFILE \
  --approve
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
kubectl annotate serviceaccount cluster-autoscaler \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::$AWS_ACCOUNT_ID:role/$GENERATED_AUTOSCALER_IAM_ROLE \
  --overwrite
kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

kubectl set image deployment cluster-autoscaler \
  -n kube-system \
  cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.19.1
