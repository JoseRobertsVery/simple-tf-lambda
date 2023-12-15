resource "aws_iam_role" "lambda_role" {
name   = "Spacelift_Test_Lambda_Function_Role"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
 
 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "null_resource" "pip_install" {
  triggers = {
    shell_hash = "${sha256(file("./src/requirements.txt"))}"
  }

  provisioner "local-exec" {
    command = "python3 -m pip install --platform manylinux2014_x86_64 --implementation cp --python-version 3.9 --only-binary=:all: -r ./src/requirements.txt -t ./src"
  }
}

# data "archive_file" "layer" {
#   type        = "zip"
#   source_dir  = "${path.module}/layer"
#   output_path = "${path.module}/layer.zip"
#   depends_on  = [null_resource.pip_install]
# }

# resource "aws_lambda_layer_version" "layer" {
#   layer_name          = "${var.function_name}-test-layer"
#   filename            = data.archive_file.layer.output_path
#   source_code_hash    = data.archive_file.layer.output_base64sha256
#   compatible_runtimes = [var.runtime]
#   compatible_architectures = ["x86_64"]
#   depends_on          = [data.archive_file.layer]
# }

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/python/hello-python.zip"
  excludes    = ["${path.module}/src/__pycache__/*.pyc"]
  depends_on  = [null_resource.pip_install]
}

resource "aws_lambda_function" "terraform_lambda_func" {
filename                       = data.archive_file.zip_the_python_code.output_path
function_name                  = var.function_name
role                           = aws_iam_role.lambda_role.arn
handler                        = "index.lambda_handler"
runtime                        = var.runtime
source_code_hash               = data.archive_file.zip_the_python_code.output_base64sha256
# layers                         = [aws_lambda_layer_version.layer.arn]
# layers                         = [ "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python39:12" ] # using a known layer
depends_on                     = [
    aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role
  ]
}