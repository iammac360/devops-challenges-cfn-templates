#!/bin/bash

ecs-cli compose \
  --file web.docker-compose.yml \
  --ecs-params web.ecs-params.yml \
  --aws-profile apper_challenge \
  --project-name sarge-express-miniapp \
  --cluster sarge-ecs-tier2-dev service up \
  --target-groups "targetGroupArn=arn:aws:elasticloadbalancing:ap-southeast-1:329511059546:targetgroup/sarge-ecs-tier2-dev-TargetGroup/ab1a5f859a2c5658,containerName=sarge-express-miniapp,containerPort=8080" \
  --launch-type FARGATE \
  --force-deployment
