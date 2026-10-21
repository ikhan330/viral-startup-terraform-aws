
# ============================================================
# GULFTECH / VIRAL STARTUP - API GATEWAY REST API
# ============================================================

# 1. API Gateway REST API
resource "aws_api_gateway_rest_api" "viral_api" {
  name        = "${var.project_name}-${var.environment}"
  description = "REST API for Viral Startup backend"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# ============================================================
# 2. GET /health
# ============================================================

resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.viral_api.id
  parent_id   = aws_api_gateway_rest_api.viral_api.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health_get" {
  rest_api_id   = aws_api_gateway_rest_api.viral_api.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.viral_api.id
  resource_id             = aws_api_gateway_resource.health.id
  http_method             = aws_api_gateway_method.health_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda_1.invoke_arn
}

# ============================================================
# 3. /ideas - GET and POST
# ============================================================

resource "aws_api_gateway_resource" "ideas" {
  rest_api_id = aws_api_gateway_rest_api.viral_api.id
  parent_id   = aws_api_gateway_rest_api.viral_api.root_resource_id
  path_part   = "ideas"
}

resource "aws_api_gateway_method" "ideas_any" {
  rest_api_id   = aws_api_gateway_rest_api.viral_api.id
  resource_id   = aws_api_gateway_resource.ideas.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ideas_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.viral_api.id
  resource_id             = aws_api_gateway_resource.ideas.id
  http_method             = aws_api_gateway_method.ideas_any.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda_1.invoke_arn
}

# ============================================================
# 4. Lambda Permission
# Allows API Gateway to invoke the Lambda function
# ============================================================

resource "aws_lambda_permission" "api_gw_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_1.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.viral_api.execution_arn}/*/*"
}

# ============================================================
# 5. API Deployment
# Redeploy when routes or integrations change
# ============================================================

resource "aws_api_gateway_deployment" "api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.viral_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.health.id,
      aws_api_gateway_method.health_get.id,
      aws_api_gateway_integration.health_lambda.id,
      aws_api_gateway_resource.ideas.id,
      aws_api_gateway_method.ideas_any.id,
      aws_api_gateway_integration.ideas_lambda.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.health_lambda,
    aws_api_gateway_integration.ideas_lambda
  ]
}

# ============================================================
# 6. DEV Stage
# ============================================================

resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.viral_api.id
  deployment_id = aws_api_gateway_deployment.api_deploy.id
  stage_name    = "dev"

  tags = {
    Name        = "${var.project_name}-${var.environment}-api"
    Environment = var.environment
  }
}

# ============================================================
# 7. API URL Output
# ============================================================

output "api_base_url" {
  description = "Base URL of the Viral Startup API"
  value       = "https://${aws_api_gateway_rest_api.viral_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}"
}

output "api_health_url" {
  description = "Health check endpoint"
  value       = "https://${aws_api_gateway_rest_api.viral_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/health"
}

output "api_ideas_url" {
  description = "Ideas endpoint"
  value       = "https://${aws_api_gateway_rest_api.viral_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.api_stage.stage_name}/ideas"
}
