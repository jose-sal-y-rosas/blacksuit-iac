# ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
# Security Groups
# # ## ## ## ## ## ## ## ## ## ## ## ## ## ##

resource "aws_security_group" "application_db_sg" {
  name        = "${var.application_name}-db-sg"
  description = "allow inbound access from VPC"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Listen request from VPC"
    protocol         = "tcp"
    from_port        = 5432
    to_port          = 5432
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, tomap({ "Name" : "sg-database" }))
}

# ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
# Subnet group
# # ## ## ## ## ## ## ## ## ## ## ## ## ## ##

resource "aws_db_subnet_group" "application_subnet" {
  name       = "${var.application_name}-db-subnet"
  subnet_ids = var.private_subnets

  tags = merge(var.tags, tomap({ "Name" : "sg-database" }))
}

# ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
# AWS RDS Information
# # ## ## ## ## ## ## ## ## ## ## ## ## ## ##

module "app_db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = var.application_name

  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts.General.DBVersions
  engine         = "postgres"
  engine_version = "12.9"
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.Types
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocate_storage
  max_allocated_storage = var.db_max_allocate_storage
  major_engine_version  = "12"
  family                = "postgres12"
  storage_encrypted     = true

  name     = var.db_name
  username = var.db_username
  password = var.db_password
  port     = "5432"

  iam_database_authentication_enabled = false

  vpc_security_group_ids = [aws_security_group.application_db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.application_subnet.name
  subnet_ids             = var.private_subnets

  multi_az            = var.db_multi_zone
  publicly_accessible = var.db_instance_accessible

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Database Deletion Protection
  deletion_protection = var.db_deletion_protection
}
