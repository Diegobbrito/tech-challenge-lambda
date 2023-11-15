provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "lanchonete_lambda" {
  function_name = "lanchonete-lambda"
  runtime       = "python3.8"
  handler       = "lanchonete-lambda.lambda_handler"
  filename      = "function.zip"
  role          = aws_iam_role.lambda_execution_role.arn

  source_code_hash = filebase64("./function.zip")

  environment {
    variables = {
      DB_HOST     = var.db_host,
      DB_USER     = var.db_user,
      DB_PASSWORD = var.db_password,
      DB_NAME     = var.db_name,
      SECRET      = var.secret
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_lanchonete_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "lanchonete_api_gateway"
  description = "API Gateway para gerar token jwt"
}

resource "aws_api_gateway_resource" "api_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "authentication"
}

resource "aws_api_gateway_method" "api_gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.api_gateway_resource.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Content-Type" = true,
  }

  request_models = {
    "application/json" = "Empty",
  }
}

resource "aws_api_gateway_integration" "api_gateway_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.api_gateway_resource.id
  http_method             = aws_api_gateway_method.api_gateway_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = aws_lambda_function.lanchonete_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  depends_on = [aws_api_gateway_integration.api_gateway_integration]
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = "dev"
}
