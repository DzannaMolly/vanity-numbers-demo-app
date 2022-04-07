# VoiceFoundry-demo-terraform
TTEC VoiceFoundry Development Project with Terraform resources

# Introduction
This is a demo app requirement project that converts phone numbers to vanity numbers and save the best 5 resulting vanity numbers and the caller's number in a DynamoDB table. It uses Amazon Connect as the main service which represents public cloud customer contact center service. Amazon Connect enables customer service representatives to respond to phone calls or chat inquiries from end customers just as if the contact center infrastructure was set up and managed on premises. Amazon Connect can interact with your own systems and take different paths in contact flows dynamically. To achieve this, invoke AWS Lambda functions in a contact flow, fetch the results, and call your own services or interact with other AWS data stores or services, . 

## Project Overview
The whole project is developed as an Infrastructure as a code with `DevOps workflow` with Terraform provider resources for AWS. This means that the execution flow is completely automated and the code can be re-usable for different environments. 
The main resources created with `Terraform` are:
- DynamoDB
- Lambda
- Api Gateway (entire integration with Lambda and importing certificates)
- AWS Connect
**NOTE:** The Lambda Function resource allows to trigger execution of code in response to events in AWS Connect. The Lambda Function itself includes source code and runtime configuration. The integration with AWS Connect, DynamoDB and API Gateway was made entirely with dependency Terraform resources.

The `backend` includes:
- The backend includes 2 Lambdas, a Dynamodb database and an AWS Api Gateway. The number convert Lambda is triggered during the AWS Contact Flow and serves to convert regular phone numbers into vanity numbers and write them into Dynamodb. The DynamoDB has only one table to save the vanity numbers, having the phone numbers as a primary id. The get number the Lambda serves to read the vanity numbers from the DynamoDB for a given phone number. The API Gateway has a GET vanity numbers endpoint that triggers the get Lambda and serves the vanity numbers to the user. The "Best" 5 numbers are considered all of the numbers that include meaningful english words in their form (meaningful is viewed as a word that is included in a library of english words used in the project), sorted by ascending order. If there are no 5 words used from the library, then "meaningful" are the randomly generated sequences of characters that map to the dial pad umbers (also in ascending order). 

`Husky Github`is used for improvement of commits, lint commit messages, run tests, lint code on commit or push. Husky supports all Git hooks. On this project is used for `Terraform Format` on pre-commit so that we don't break the automation flow when pushing code to Github.

For `CI/CD` integration `GitHub Actions` are implemented along with `Terraform` which automates CI/CD configuration and Terraform workflow. GitHub Actions sets up and configures the Terraform CLI in the Github Actions workflow. This allows most Terraform commands to work exactly like they do locally.
**NOTE:** The pipeline is set in `./github/workflows/pipeline.yml` which is the integration automation workflow between Terraform and GitHub Actions.

[Disclaimer]This repo consist of source code, pipeline and diagram for this Project.

## Prerequisites

1. Setting up account credentials and instalment of providers:
- [AWS Account](https://aws.amazon.com/console/). Download your security credentials somewhere safe.
- [AWS CLI](https://awscli.amazonaws.com/AWSCLIV2.msi). Set `AWS Configure` with your credentials.
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) Download and install Terraform.
- [Node.js](https://nodejs.org/dist/v16.14.0/node-v16.14.0-x64.msi). Download and install NodeJS.

After we have everything downloaded and set, we need to clone the GitHub [repository](https://github.com/DzannaMolly/VoiceFoundry-demo-terraform) at a location on your local machine and then `cd` to the `VoiceFoundry-demo-terraform` directory. This is the root of the project and all of the commands explained below are executed relative to this directory. 

2. [Terraform `Remote State` in AWS S3](https://www.terraform.io/language/settings/backends/s3):
- When a terraform stack is deployed, terraform creates a state file, which keeps track of what resources have been deployed, all parameters, IDs, dependencies, failures and outputs defined in your stack. One manual step is required and that is creating a S3 Bucket in AWS where our state will reside. Bucket name should be unique and will be later referenced in our TF provider main file.

3. [Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). 
- First and foremost we need to set the Terraform provider so that our infrastructure is provisioned and the structure is created according the latest version of Terraform resources for the AWS Provider. Our provider is set in a file called `main.tf` where we referenced our state bucket name and key (key is the folder where the state file is stored of the state file itself).
**NOTE:** After creating the remote state and main.tf file, initialization of the code needs to be done with the following command:
Change directory to where the repo is cloned and run:

```bash
terraform init
```
```bash
terraform plan
```
```bash
terraform apply
```
This will initiale the backend remote state of our configuration changes and where to deploy our infrastructure resources.

4. [Terraform with GitHub Actions](https://learn.hashicorp.com/tutorials/terraform/github-actions):
- Instead of manually executing repetitive commands, we should automate our workflow. For the purpose of simplicity, `Terraform with GitHub Actions` is configured. The pipeline is located in `./github/workflows/pipeline.yml`, it contains all the commands, name of the branches, environments and reference for our secrets to be able to automatically deploy our resources.
**NOTE:** Very important for this integration is to create a `IAM Role` to give Github Actions permission to perform actions in AWS which can be found in this repo:
(https://github.com/aws-actions/configure-aws-credentials). 

5. [NodeJS](https://docs.npmjs.com/cli/v8/commands/npm-install):
- Next, we need initialization of NodeJS packages and dependencies. In the terminal where our repo is, run the following command:

```bash
npm i
```
This command installs a package and any packages that it depends on.

6. [Husky](https://typicode.github.io/husky/#/?id=install):
- But we don't want to mannualy format our code don't we ? For this purpose we are going to install `Husky` which will automatically create a `.husky` folder with a `pre-commit` file where for our purposes need to set the following command `terraform fmt && git add -A .` that will format our code structure when we commit our code and this way our build process won't fail due to indentation or any kind of format mistakes. Formating is very important command in Terraform and in yaml files in general. Install `Husky` with the following command:

```bash
npm install husky
```

## About our source code

1. The Backend
The backend consists of two parts:
- First Lambda function called `vanity-number-convert.js` written in NodeJS serves to convert regular phone numbers into vanity numbers and write them into Dynamodb.
- Second Lambda function called `vanity-number-get.js`written in NodeJS serves to read the vanity numbers from the DynamoDB for a given phone number.

2. Terraform Resources
- The main resources (described above), are build in Terraform. 
- **AWS Connect** TF resource creates only instance and Lambda function association. The `Contact Flow` is created mannualy through the console wizard. That flow is then exported as a json file which we imported in our repo as a separate file. 
- **DynamoDB** creates a Table with attribute called `id` which is our Partition key. Basic configuration that will serve our purpose for this project.
- **Lambda** resources that contains our backend source code which we integrated with DynamoDB and later with Api Gateway as well, so that when a trigger occurs it knows to which resources is dependent. 
- **Api Gateway** resources uses a GET vanity numbers endpoint that triggers the get Lambda and serves the vanity numbers to the user.Also, contains depended resources for the service to be completely deployed along with Self-Signed TLS Certificate for Testing and domain name `uri` that can be used for testing our requests (since we don't have a FrontEnd application).

**NOTE:** At the end of our final deployment of our resources and succesfull testing that the numbers are written in the DynamoDB table, we should claim a number in the AWS Connect Dashboard 


## Architecture
The architecture diagram for the infrastructure and backend is located in the `./diagram` directory. It's stored in .png format.

## Conclusion

This project is developed from a DevOps perspective, with automated workflow and reusable code.

Why I have choosed to work with Terraform instead of the AWS development tools or Cloudformation is because Terraform is just far more powerful, particularly when it comes to the data sources. For me the biggest CloudFormation issue is forcing you do use either import/export in order to do cross-stack referencing (which creates unnecessary dependencies between the two stacks) or else forcing you to use Lambda to do the same. This is something that Terraform handles without issue and without creating dependencies. Terraform is very reusable and provider consistent when it comes to deploying large infrastructures for several environments. Also, the code structure is more agile when it comes to formating and mapping. 

The most challeging part for me was using a backend language like NodeJS which I have a basic understanding and to implement it in a Infrastructure as a Code configuration like Terraform. The process it self to see how that can be called in the infrastructure was the most challenging and exciting part, rather than developing the programming language. 

I also made a research about the AWS Connect service which is a newly service launched in 2017. So after that in 2020 it launched AWS CloudFormation support for users, user hierarchy groups, and hours of operation. So some time later in 2020 Terraform came along with support for this service as well. There are some `cons` when it comes to automating this service:
- The underlying APIs are new, inconsistent, and incomplete. For instance the way that you define call flows with the API is not the same format that you get when you export it from the designer.
- It has no option for creating completely automatically the `Contact Flow` either with Cloudformation nor with Terraform, that part is manually made and afterwards the the flow is exported as a file, than imported in your code as a json block code (which is pointless in my opinion).
- There is no option to create an administrator access though code when creating an Connect instance. In that case to be able to connect the dashboard you have to go though the `emergency log` which is not a good practice. 
- The number claiming is limited to one number only in the free tier( which I have spend when trying out the service for the first time).

I did one shorcut on this project however and that is the CI/CD flow, where I used GitHub Actions instead of creating Terraform pipelines with AWS CodeCommit/CodeBuild/CodeDeploy and CodePipeline. That is because I am using the AWS Free tier and have exhausted those resources on a monthly basis so this was a more suitable approach for that purpose. 

I did not provide a Front-End application because it's not my domain of skills. I work mostly DevOps implementations and managing infrastructures in the Cloud. 

There is room for improvements of course where we can make this code even more reusable with modules and implement the pipelines accordingly for this configuration. 

