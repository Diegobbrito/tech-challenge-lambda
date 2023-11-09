provider "aws" {
  region = "us-east-1"
}

# Cria a função Lambda
resource "aws_lambda_function" "my_lambda_function" {
  function_name = "lambda-function"
  handler = "index.handler"
  role = aws_iam_role.lambda_role.arn
  runtime = "nodejs14.x"
  filename = "./lambda.zip"
  source_code_hash = filebase64sha256("./lambda.zip")
  environment {
    variables = {
      DB_HOST     =  "${var.db_host}"
      DB_USER     =  "${var.db_user}"
      DB_PASSWORD =  "${var.db_password}"
      DB_DATABASE =  "${var.db_name}"
    }
  }
}

#Role IAM para a função Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  #Política para permitir que a função Lambda envie logs para o CloudWatch
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

#Política para permitir que a função Lambda acesse o RDS
resource "aws_iam_policy" "lambda_rds_policy" {
  name = "lambda-rds-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds-db:connect"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Anexa a política à role da função Lambda
resource "aws_iam_role_policy_attachment" "lambda_rds_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_rds_policy.arn
}

# Cria um API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "lanchonete-api"
  description = "API Gateway"
}

# Cria um recurso no API Gateway
resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "lanchonete-resource"
}

# Cria um método no API Gateway
resource "aws_api_gateway_method" "my_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Conecta o método à função Lambda
resource "aws_lambda_permission" "my_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/${aws_api_gateway_method.my_method.http_method}${aws_api_gateway_resource.resource.path}"
}

# Associa a integração ao método
resource "aws_api_gateway_integration" "my_integration" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.resource.id
  http_method          = aws_api_gateway_method.my_method.http_method
  type                 = "AWS_PROXY"
  uri                  = aws_lambda_function.my_lambda_function.invoke_arn
  integration_http_method = "POST" # ou o método de sua escolha
}

# Deploy da API Gateway
resource "aws_api_gateway_deployment" "my_deployment" {
  depends_on    = [aws_api_gateway_integration.my_integration]
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
}
