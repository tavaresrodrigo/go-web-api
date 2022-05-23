# CI/CD Pipeline for an AWS Fargate task on ECS [ongoing]

A complete CI/CD pipeline defined through Terraform that implements CodePipeline, CodeBuild, CodeStar, CodeDeploy, ECS, Fargate among other resources that offers a continuous deployment infrastructure for a sample web-api written in go.

![Kubernetes Cluster Architecture](/diagrams/FargatePipeline.jpg)

* This diagram was drawn using [app.diagrams.net](https://app.diagrams.net/), and is available as XML compressed standard deflate format on [diagrams/KubeadmClusterAWS](/diagrams/FargatePipeline). Refer to https://drawio-app.com/extracting-the-xml-from-mxfiles/ if you want to get the raw XML.


All the changes on the application will take place in the GitHub repository where the source code is stored, every new push event will trigger the CodeStart Connection via webhook, this connection installs a repository webhook on the GitHub App that subscribes to GitHub push type events, when a code change is made to the code repository, Code Start triggers the event to deploy a new application version through CodePipeline. 

CodeBuild downloads the source code into the build environment and then uses the build specification (buildspec) to build the new container image that will later be scanned by Trivy searching for vulnerabilitites. In this step the container Image is scanned, if CRITICAL vulnerabilities are found, the build process, and manual intervention is required fix the vulnerabilities to be able to proceed.

CodeDeploy automates the application deployment on Amazon ECS a service. The ECS service will deploy a new Fargate task based on the task definition to create a new container from the latest image.  The Fargate Container logs (STDOUT and STDERR I/O streams) will be streamed to a CloudWatch group as recommended by the Twelve-Factor App XI. Logs Treat logs as event streams.

The application load Balancer is created together with a target group and the health check criteria for targets that are registered within that group, in this case the Fargate task. At the end of the Terraform deploy there is an output that will inform the Load Balancer endpoint.

It's important to highlight the most important part of the whole thing, which are the users/developers. 

> "Any fool can write code that a computer can understand. Good programmers write code that humans can understand."
> Martin Fowler.

## Privisioning resources on AWS

### Requirements

Before you start make sure you have:

* An active AWS Account [How do I create and activate a new AWS account?](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/) 
* Latest version of the AWS CLI. [Installing or updating the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* Set up AWS Credentials and Region for Development. [Setting Credentials](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html)
* Terraform client installed. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)


### Deploying the AWS resources step by step

1  - Initialize the working directory with the Terraform configuration files.

```
$ terraform init
```

2 -  Deploy the resources on AWS.

```
$ terraform apply
```

3 - When the process is concluded the aws_alb.application_load_balancer.dns_name will inform the ALB endpoint users will use to have access to the application. 

### Don't forget to remove the resources

Once you have completed this lab, you can run a terraform destroy to to remove all objects managed by this Terraform configuration.

```
$ terraform destroy
```

## Contributing

Are you willing to contribute? Have you seen any errors, typos ? Do you want to suggest any improvement? Please don't be afraid to raise an issue, I will be happy to collaborate. You don't even need to know Terraform, AWS, Containers or anything related to these topics I have approached here, I truly believe in the power of collaboration and I will be happy to assist you in your first PR.
