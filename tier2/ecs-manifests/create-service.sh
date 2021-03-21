#!/bin/bash

ecs-cli compose \
  --file web.docker-compose.yml \
  --ecs-params web.ecs-params.yml \
  --aws-profile sarge-apper \
  --project-name sarge-express-miniapp \
  --cluster sarge-ecs-tier2-dev service up \
  --target-groups "targetGroupArn=arn:aws:elasticloadbalancing:ap-southeast-1:329511059546:targetgroup/sarge-ecs-tier2-dev-TG/df70d122f3ca9412,containerName=sarge-express-miniapp,containerPort=8080" \
  --role arn:aws:iam::332913802239:role/AmazonECSServiceRole \
  --force-deployment

