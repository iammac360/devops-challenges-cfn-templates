#!/bin/bash

ecs-cli compose \
  --file web.docker-compose.yml \
  --ecs-params web.ecs-params.yml \
  --aws-profile newmbstag \
  --project-name mbhive-web \
  --cluster mbhive-ecs service up \
  --target-groups "targetGroupArn=arn:aws:elasticloadbalancing:ap-southeast-1:332913802239:targetgroup/mb-tg-20200904034345344600000001/e4eddb7aebf7e112,containerName=mbhive-web,containerPort=8080" \
  --role arn:aws:iam::332913802239:role/AmazonEC2ContainerServiceRole \
  --force-deployment

