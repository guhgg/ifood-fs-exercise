terraform{
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    version = "~> 3.0"
    region = var.aws_region
}
