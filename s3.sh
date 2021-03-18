#!/usr/bin/env bash

aws s3api create-bucket --bucket sarge-cfn --region ap-southeast-1 --profile apper_challenge --create-bucket-configuration LocationConstraint=ap-southeast-1
