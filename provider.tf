terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = "ap-south-1"
  alias  = "India"
}

provider "aws" {
  region = "us-east-1"
  alias  = "USA-primary"
}

provider "aws" {
  region = "us-west-1"
  alias  = "USA-secondary"
}
