terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-fcb572ff21"
    key            = "terraform/tf-gitops"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.60"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "sandbox"
      Owner       = "willy2544"
      Repo        = "tf-gitops"
    }
  }
}