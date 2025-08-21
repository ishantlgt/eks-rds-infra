resource "aws_ecr_repository" "project_repos" {
  for_each = toset(var.images)

  name = "${each.key}-${var.environment}"

  image_scanning_configuration {
    scan_on_push = true
  }
 force_delete = true
  tags = {
    Name        = "${each.key}-${var.environment}-ecr"
    Environment = terraform.workspace
  }
}

resource "aws_ecr_lifecycle_policy" "project_repo_lifecycle" {
  for_each = toset(var.images)

  repository = aws_ecr_repository.project_repos[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain only last 10 untagged images"
        selection = {
          tagStatus     = "untagged"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
