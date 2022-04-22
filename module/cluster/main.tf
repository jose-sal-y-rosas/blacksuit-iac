resource "aws_ecs_cluster" "main" {
  name               = var.application_name
  capacity_providers = ["FARGATE"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}
