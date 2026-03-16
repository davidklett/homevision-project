terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "archive_file" "image_processor" {
  type        = "zip"
  source_dir  = "../lambda/image_processor"
  output_path = "../lambda/image_processor.zip"
}

data "archive_file" "text_processor" {
  type        = "zip"
  source_dir  = "../lambda/text_processor"
  output_path = "../lambda/text_processor.zip"
}
