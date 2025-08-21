resource "aws_secretsmanager_secret" "this" {
  name        = "${var.project_name}-${var.environment}-${var.secret_name}"
  description = var.description
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(var.secret_values)
}
