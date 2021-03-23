#!/bin/bash

CLUSTER_NAME=sarge-eks-tier3-dev
AWS_ACCOUNT_ID=329511059546
NAMESPACE=kube-system
AWS_PROFILE=apper_challenge 

AWS_PROFILE=apper_challenge eksctl create cluster -f cluster.yaml
AWS_PROFILE=apper_challenge eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --approve

curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.3/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json \
    --profile apper_challenge

AWS_PROFILE=apper_challenge eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=$NAMESPACE \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

AWS_PROFILE=apper_challenge eksctl get iamserviceaccount --cluster $CLUSTER_NAME --name aws-load-balancer-controller --namespace $NAMESPACE
