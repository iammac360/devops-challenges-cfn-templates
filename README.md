# Sarge Apper Devops Technical Challenge Cloudformation Templates and Deployment Manifests 

![Branding](https://media-exp1.licdn.com/dms/image/C510BAQHAhem3MAGMOw/company-logo_100_100/0/1548069481911?e=1619654400&v=beta&t=RMd-5dJ-YxQ475FznaYdeTFtQLf1NPNGCIw8g_Z5q-8) 

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


&nbsp;
* What you will build should satisfy the challenge statement/requirements.
&nbsp;
* Your code should be human readable and uses intellectual words.
&nbsp;
* We at Apper, take code organization and application architecture quite seriously.
&nbsp;
* The challenge are divided into three tiers based on the knowledge and experience required to complete them.
  **Note**: *It's ok not to finish all of them but completing higher tier is very much encourage.*
&nbsp;
* Keep in touch with us and feel free to message us for questions and clarifications.

## The Challenge

Challenges are divided into three tiers based on the knowledge and experience
required to complete them.

| Tier | DevOps Profile                                                                                                                                                |
| :--: | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  1   | DevOps in the early stages of their learning journey. Those who are typically experienced deploying user-facing applications such as nodejs apps, ruby web apps, and php laravel apps on virtual machines or in cloud providers such as AWS, GCP, Azure or Heroku. Someone who can leverage ElasticBeanstalk. Also has deep knowledge on Linux Fundamentals and Databases that can leverage AWS RDS for MySQL and PostgreSQL and etc. Basic understanding on AWS basic services such as  VPC, Security Groups, S3, Route53, Cloudfront, Application Load Balancer, EC2 and IAM.                |
|  2   | DevOps at an intermediate stage of learning and experience. Deep understanding on Docker and Containerization. Can deploy containerize apps or api services on Amazon ECS. They are comfortable in automation tools such as Cloudformation or Terraform and Docker. Comfortable using development tools such as AWS CodePipeline, CodeBuild, CodeCommit and CodeDeploy for CI/CD. Have experience automating applications using scripts and other third party libraries. |
|  3   | DevOps who have all of the above, and are learning more advanced techniques like implementing microservices applications using Kubernetes and can leverage AWS EKS                   |


## Requirements
**🌟 What You’ll need to build 🌟**

This repository includes a simple and very minimal express nodejs app in the root directory (**./express-minapp**). What you need to do is use this user-facing application and deploy it on AWS. AWS Account will be provided by apper.ph. The deployment and infrastructure varies differently on each tier. Please refer to the diagram and instructions on each tier.

**🌟 What you are encouraged to use and our judging criteria 🌟**

Automation and CI/CD are the heart of DevOps. So you're encourage to use development tools, CI/CD tools and automation tools accordingly at all times.

![System diagram](assets/release.jpg)

* Implement IaC (Infrastructure as a code) leveraging AWS Cloudformation
* Implement CI/CD using AWS Codepipeline, CodeCommit, CodeBuild and CodeDeploy (Optional)
* Reusability of IaC templates
* Application is functional
* Securing the application using AWS Security Groups, AWS Certificate for HTTPS and proper AWS services access-control using IAM Roles.
* High Availability
* Auto Scaling

&nbsp;
### :ledger: Tier-1: Beginner Challenge
**Architecture diagram - ElasticBeanstalk**

![System diagram](assets/ElasticBeanstalk.png)

* Implement VPC
* Implement RDS
* Implement SecurityGroups
* Implement IAM Roles and Access Policies
* Implement Route53 -> Cloudfront -> Application Loadbalancer -> Elastic Beanstalk Integration and Connectivity (use apperdevops.com)
* Implement Elastic Beanstalk Web Server and RDS Connectivity
* Implement Elastic Beanstalk Custom Config using .ebextensions
* Implement CI/CD to ElasticBeanstalk using AWS CodePipeline. (No manual upload of application zip file.)

&nbsp;
### :ledger: Tier-2: Intermediate Challenge
**Architecture diagram - AWS ECS** 
![System diagram](assets/ECS.png)

* Implement VPC
* Implement RDS
* Implement SecurityGroups
* Implement IAM Roles and Access Policies
* Implement Route53 -> Cloudfront -> Application Loadbalancer -> AWS ECS Integration and Connectivity (use apperdevops.com)
* Implement AWS ECS Web Server and RDS Connectivity
* Dockerize the application. Add Dockerfile.
* Push image to AWS ECR
* Implement CI/CD to AWS ECS using AWS CodePipeline.

&nbsp;
### :ledger: Tier-3: Advanced Challenge
**Architecture diagram - Kubernetes AWS EKS**
![System diagram](assets/EKS.png)

* Implement VPC
* Implement RDS
* Implement SecurityGroups
* Implement IAM Roles and Access Policies
* Implement EKS Managed Nodegroups
* Implement Route53 -> Cloudfront -> Application Loadbalancer -> AWS EKS microservices Integration and Connectivity (use apperdevops.com)
* Implement AWS EKS microservices and RDS Connectivity
* Implement readable kubernetes manifest files
* Implement CI/CD to AWS EKS using AWS CodePipeline.

&nbsp;
## ✅ Submission Checklist

* Here at Apper, we use Basecamp as our official communication channel and project management tool. We will add you during the onboarding process.
&nbsp;
* AWS Account will be provided by Apper. It will be provision during the onboarding process.
&nbsp;
* Create your own Github repository. (e.g. repo name: surname-devops-challenge-project-id)
&nbsp;
* Commit all your work on the repository. It should include all the templates, manifest, configuration or any files that you've created to implement each challenges. We will review it base on our judging criteria stated above.
&nbsp;
* Tier 1 and 2 completion should be 1 week.
&nbsp;
* Tier 1, 2 and 3 completion should be 2 weeks.
&nbsp;  
* Submit the repo name, repo link and commit hash on or before the final day (11:59:59 UTC+8) of the given time frame on the DevOps Candidate message thread on our Basecamp.
&nbsp;
* Submit the working url on or before the final day (11:59:59 UTC+8) of the given time frame on the DevOps Candidate message thread on our Basecamp. We should be able to access the URL/ and URL/health.
&nbsp;
![System diagram](assets/working-page.jpg)
