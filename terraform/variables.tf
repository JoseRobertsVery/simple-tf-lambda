variable "region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}

variable "path_source_code" {
  default = "lambda_function"
}

variable "function_name" {
  default = "Spacelift_Test_Lambda_Function"
}

variable "runtime" {
  default = "python3.9"
}

variable "output_path" {
  description = "Path to function's deployment package into local filesystem. eg: /path/lambda_function.zip"
  default = "lambda_function.zip"
}

variable "distribution_pkg_folder" {
  description = "Folder name to create distribution files..."
  default = "terraform/src"
}

variable "bucket_for_videos" {
  description = "Bucket name for put videos to process..."
  default = "aws-lambda-function-read-videos"
}