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

output "dns_name" {
    value = aws_alb.server_load_balancer.dns_name
}