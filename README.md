# Sarge Apper Devops Technical Challenge Cloudformation Templates and Deployment Manifests 

![Branding](https://media-exp1.licdn.com/dms/image/C510BAQHAhem3MAGMOw/company-logo_100_100/0/1548069481911?e=1619654400&v=beta&t=RMd-5dJ-YxQ475FznaYdeTFtQLf1NPNGCIw8g_Z5q-8) 


## Background

My solution to all the challenges is to provide a common environment for all resources, instead of creating a dedicated VPC, RDS Database and so on(which is a waste of money since the app is the same for all tiers)
I also decided to provision a single pipeline for all the challenges since the app and the build stage is the same.

## Basic Enviroment setup

The challenges expected us to provision a working application, highly available, auto scaled, secured(HTTPS, Security Groups, resource ACL thru IAM roles) and utilizing the CI/CD pipelines.
Also, the resources must be provisioned with IaC(AWS Cloudformation).

My VPC environment setup comprises of:
* A VPC (10.33.0.0/16)
* 2 Public Subnets for each AZ(a and b)
* 2 Private Subnets for each AZ(a and b)
* 2 Database Subnets for each AZ(a and b)
* Internet Gateway
* 2 Nat Gateways for each AZ(a and b) with dedicated EIP each. Attached to both private subnets
* 1 Public Route Table. Attached to public subnets
* 2 Private Route Tables. Attached to both private Nat gateways

This is to ensure that my VPC is HA. I also provisioned the elastic beanstalk, ECS and EKS in an HA setup and utilizes auto scaling.

## Prerequisites:

You need to have the following in order for the provisioning scripts to work:

* AWS IAM User key pair - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html
* AWS CLI v2 - https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
* ECS CLI - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html

## Steps to provision core resources(VPC, RDS, IAM Roles/Policies, ECS, PyPlate CF Macro and Lambda handler, Certificates, ECS Cluster)

1. Clone this repository

```
git clone ssh://git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/sarge-cfn-templates

cd sarge-cfn-templates

```

2. Create an s3 bucket. This is needed to store the packaged Cloudformation templates

```
BUCKET_NAME=enter_your_bucket_name # e.g. sarge-cfn
 # Reference: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html
AWS_PROFILE=enter_your_aws_profile_reference
aws s3api create-bucket \
--bucket $BUCKET_NAME \
--region ap-southeast-1 \
--profile $AWS_PROFILE \
--create-bucket-configuration LocationConstraint=ap-southeast-1
```

3. Once the s3 bucket is ready, you can package the CFN templates. NOTE: this is a nested stack

```
BUCKET_NAME=enter_your_bucket_name # e.g. sarge-cfn
 # Reference: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html
AWS_PROFILE=enter_your_aws_profile_reference
aws cloudformation package \
--template-file template.yaml \
--output-template packaged.yaml \
--s3-bucket $BUCKET_NAME \
--profile $AWS_PROFILE
```

4. Deploy the packaged cfn template `template.yaml`

```
aws cloudformation deploy \
--stack-name SargeCommon-stack \
--template-file packaged.yaml \
--capabilities CAPABILITY_AUTO_EXPAND CAPABILITY_IAM CAPABILITY_NAMED_IAM \
--profile apper_challenge
```

## Steps to provision Tier1 Challenge(Elastic Beanstalk)

1. Clone the sarge-express-miniapp repo

```
git clone ssh://git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/sarge-express-miniapp

cd sarge-express-miniapp
```

2. Using eb cli tool, initialize a new elastic beanstalk config 

```
# Reference: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html
AWS_PROFILE=enter_your_aws_profile_reference 

eb init --profile $AWS_PROFILE

# Select a default region: 7 - ap-southeast-1
# Select [ Create new Application ]
# Enter Application Name: Any name you want
# Select a platform.: 7 - Node.js
# Select a platform branch: 1 - Node.js 14 running on 64bit Amazon Linux 2
# Do you wish to continue with CodeCommit? (Y/n): Y (But it's up to you if you want to use other repositories)
# Select  a repository: Up to you
```

3. After initializing eb config, create a new environment with sample app

```
eb create --sample --vpc
```

4. Set the necessary environment variables. You can check the host name at your provisioned RDS instanec

```
# Replace the values
PASSWORD=somedbpassword
HOST=somedbisntance.c4abcdef1234.ap-southeast-1.rds.amazonaws.com
eb setenv PASSWORD=$PASSWORD USERNAME=sarge DATABASE=sarge HOST=$HOST
```

5. After you set the necessary env vars, you can now deploy the app

```
eb deploy
```

## Steps to provision Tier2 Challenge(ECS)

1. Assuming you already have the `sarge-cfn-templates` project on your machine. Go to:

```
cd sarge-cfn-templates/tier2/ecs-manifests
```

2. Go to the AWS management console and search `Parameter store` Feature. Or just click this ![https://ap-southeast-1.console.aws.amazon.com/systems-manager/parameters/?region=ap-southeast-1&tab=Table] https://ap-southeast-1.console.aws.amazon.com/systems-manager/parameters/?region=ap-southeast-1&tab=Table

3. Click `Create parameter` and create the following:
  * Parameter Name: sarge.DB_DATABASE
    Parameter Type: Secure String
    Parameter Value: (your database name)
  * Parameter Name: sarge.DB_HOST
    Parameter Type: Secure String
    Parameter Value: (your database host. You can check the RDS console for the host reference)
  * Parameter Name: sarge.DB_PASSWORD
    Parameter Type: Secure String
    Parameter Value: (your database password)
  * Parameter Name: sarge.DB_USERNAME
    Parameter Type: Secure String
    Parameter Value: (your database username)

4. Once you have all the SSM parameter set, you can now create the initial ECS service and task definition using `ecs-cli`.

```
# You can check the provisioned target group arn at the aws management console
TARGET_GROUP_ARN=arn:aws:elasticloadbalancing:ap-southeast-1:329511059546:targetgroup/sarge-ecs-tier2-dev-TargetGroup/ab1a5f859a2c5658
AWS_PROFILE=apper_challenge

ecs-cli compose \
  --file web.docker-compose.yml \
  --ecs-params web.ecs-params.yml \
  --aws-profile $AWS_PROFILE \
  --project-name sarge-express-miniapp \
  --cluster sarge-ecs-tier2-dev service up \
  --target-groups "targetGroupArn=$TARGET_GROUP_ARN,containerName=sarge-express-miniapp,containerPort=8080" \
  --launch-type FARGATE \
  --force-deployment
```

## Pipeline Link:

NOTE: This is a mono pipeline for all the 3 challenges. The source comes from codecommit repository.

https://ap-southeast-1.console.aws.amazon.com/codesuite/codepipeline/pipelines/sargeapper-cicd/view?region=ap-southeast-1

## Working URLs:

* Tier 1: https://sarge-tier1.apperdevops.com
* Tier 2: https://sarge-tier2.apperdevops.com
* Tier 3: https://sarge-tier3.apperdevops.com
