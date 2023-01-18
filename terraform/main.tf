terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 2.0"
        }
    }
}


provider "aws" {
    region = "us-east-1"
}

resource "aws_ecs_cluster" "my_sandbox_cluster" {
    name = "my-sandbox-cluster"   
}