## Infrastructure as Code

This is a demo for IaC with Terraform to show an [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### What is it?

blacksuit-iac is a project to show auto scale feature in AWS ECS, considering:
- Load Balancer
- Public and Private network
- Security Groups
- AWS RDS and Read Replicas
- Route53 to handle the subdomains
- AWS ECS, AWS ECR, AWS Cluster and ASG
- IAm, Roles and Policies
- AWS Cloudwatch

## Contents
- [Demo: Infrastructure as Code](#infrastructure-as-code)
  - [What is it?](#what-is-it)
- [Contents](#contents)
- [Application Architecture](#application-architecture)
- [Cloud Deployment](#cloud-deployment)
  - [Basic Network Setups](#basic-network-setups)
    - [Immutable Application Image and Container Release](#immutable-application-image-and-container-release)
- [Project Dependencies](#project-dependencies)
- [Using Terraform](#using-terraform)
- [Project Requirements](#project-requirements)
- [Links](#links)
- [Troubleshooting](#troubleshooting)

## Application Architecture

![Application Architecture](app_architecture.svg)

Our project consists of several parts:

- Frontend part ([React.js app](https://reactjs.org/)) - UI application on a container.
- Backend part ([Flask app](https://flask.palletsprojects.com/)) - Expose data for JSON files in a REST application, 
  writing and reading from database. 
- Application Database - [PostgreSQL database](https://www.postgresql.org/)

## Cloud Deployment

We will use [ECS](https://aws.amazon.com/ecs/) for this deployment.

We have developed this project as a multi container application so schedulers are a great deployment choice.

This example might give you some ideas of your own deployment process.

### Basic Network Setups

As part of CI/CD, this project deploy into Amazon ECS with a private/public subnet configuration CI/CD

In this configuration:

* The application containers are deployed into a private subnet with _egress-only_ internet access through a [NAT Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html).
* User access requests come through an Amazon [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) that sits within the public subnet.
* Security groups are maintained at both the load balancer level and the application container level. Network communication between containers is managed internally by the container scheduler service, in this case ECS.
* Code changes happen through an _immutable image deployment_ so there is no need for a live SSH connection into running containers. This reduces the vulnerable attack surface and also simplifies deployment operations.

![Network Setup](blacksuit_ecs.svg)

#### Immutable Application Image and Container Release

Containers are spawned from Docker images at run time. Building container images for each code change is a simple way evolving the application after initial setup.

This can be done manually when you're in the early stages of your development or later on when you get a CI/CD system setup for rapid testing and deployment.

You can learn more about immutable deployments here: [link1](https://medium.com/sroze/why-i-think-we-should-all-use-immutable-docker-images-9f4fdcb5212f) and [link2](https://www.hashicorp.com/resources/what-is-mutable-vs-immutable-infrastructure/).

> Base Image Build --> Add Code Change --> Application Image --> App Image to Container Registry

Container services like ECS also work well with the cloud container registry service, in the case of Amazon [ECR](https://aws.amazon.com/ecr/). For example if you choose ECS to deploy your containers at runtime you can configure your ECS cluster to listen for image updates to the ECR registry.

This means that newly uploaded images are gracefully deployed into the cluster and the only thing you need to worry about is building and testing the image properly with the correct code change.

> Application Image --> Auto Pickup by Container Service

## Project Dependencies

- [Terraform Workspaces](https://www.terraform.io/docs/language/state/workspaces.html)

## Using Terraform

Create the specific environment: (as an example for dev)

```
terraform workspace new dev
```

Select the specific environment: (as an example for dev)

```
terraform workspace select dev
```

Run plan for execution. As an example, the expected plan would be called: 20210907_01_update_core_infrastructure.

On Linux or MacOS:

```
terraform plan --out=20210907_01_Update_core_infrastructure -var-file=terraform.dev.tfvars
```

On Windows:

```
terraform plan --out 20210907_01_Update_core_infrastructure -var-file terraform.dev.tfvars
```

Apply specific execution plan

```
terraform apply "20210907_01_Update_core_infrastructure"
```

## Project Requirements

1. Buy and register a domain in AWS Route53 or migrate from a domain service (example: GoDaddy)
2. Use AWS ACM to generate a wildcard certificate
3. Create a container registry (ECR) to deploy frontend container
4. Create a container registry (ECR) to deploy backend container 

## Links

- https://eazytutorial.com/index.php/2021/10/23/aws-certificate-manager-create-a-ssl-certificate-for-a-godaddy-domain/
- https://www.radishlogic.com/aws/using-godaddy-domain-in-aws-route-53/
- https://antmedia.io/ssl-from-aws-certificate-manager-for-domain-name/
- https://www.radishlogic.com/aws/creating-a-public-ssl-tls-certificate-in-aws-certificate-manager/

## Troubleshooting
