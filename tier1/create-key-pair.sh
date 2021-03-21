#!/bin/bash

aws ec2 create-key-pair --key-name sarge-apper --profile apper_challenge | tee sarge-apper.pem
