// sumEnv test application
terraform {
	required_version = "~> 1.2.9"

	required_providers {
		archive = {
			source = "hashicorp/archive"
			version = "~> 2.0"
		}
		aws = {
			source  = "hashicorp/aws"
			version = "~> 3.0"
		}
	}
}

// 1) Provide your own access and secret keys so terraform can connect
//    and create AWS resources (e.g. our lambda function)
provider "aws" {
	access_key = "AWS_ACCESS_KEY_ID"
	secret_key = "AWS_SECRET_ACCESS_KEY_ID"
	region="us-east-2"
}

locals {
	function_name = "sumEnv3"
	handler = "sumEnv3.lambda_handler"
	runtime = "python3.8"
	timeout = 6
	zip_file = "sumEnv3.zip"
}

data "archive_file" "zip" {
	excludes = [
		".env",
		".terraform",
		".terraform.lock.hcl",
		"docker-compose.yml",
		"main.tf",
        "sumEnv.zip",
		"terraform.tfstate",
		"terraform.tfstate.backup",
        "terraform.exe",
		local.zip_file,
	]
    source_dir =  path.module
	type = "zip"

	// Create the .zip file in the same directory as the index.js file
	output_path = "${path.module}/${local.zip_file}"
}

data "aws_iam_policy_document" "default" {
	version = "2012-10-17"
	statement {
		actions = ["sts:AssumeRole"]
		effect = "Allow"

		// Let the IAM resource manage our (future) lambda resource
		// https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_principal.html#principal-services
		principals {
			identifiers = ["lambda.amazonaws.com"]
			type = "Service"
		}
	}
}

resource "aws_iam_role" "default" {
	assume_role_policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role_policy_attachment" "default" {
	// In addition to letting our IAM resource connect to our (future) lambda
	// function, we also want to let our IAM resource connect to other AWS services
	// like Cloudwatch for to see our "console.log"
	// https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html#permissions-executionrole-features

	policy_arn  = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
	role = aws_iam_role.default.name
}

resource "aws_lambda_function" "default" {
	// Function parameters we defined at the beginning
	function_name = local.function_name
	handler = local.handler
	runtime = local.runtime
	timeout = local.timeout

	// Upload the .zip file Terraform created to AWS
	filename = local.zip_file
	source_code_hash = data.archive_file.zip.output_base64sha256

	// Connect our IAM resource to our lambda function in AWS
	role = aws_iam_role.default.arn

	environment {
		variables = {
			NODE_ENV = "dev"
			SOME_API_KEY = "123456"
		}
	}
}

module "sumEnv3" {
	source = "github.com/bspeiser/centene.git"
}

resource "aws_s3_bucket" "sumEnv3Bucket"{
  bucket = "centene-sum-env3"
  tags = {
    Name = "sumEnv"
  }
}
resource "aws_s3_bucket_object" "inputdir" {
  bucket = "${aws_s3_bucket.sumEnv3Bucket.bucket}"
  key    = "input//"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "outputdir" {
  bucket = "${aws_s3_bucket.sumEnv3Bucket.bucket}"
  key    = "output//"
  content_type = "application/x-directory"
}
