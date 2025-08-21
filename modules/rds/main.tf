resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-${var.environment}-rds-subnet-group"
  subnet_ids = var.private_app_subnet_ids  

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-subnet-group"
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier             = "${var.project_name}-${var.environment}-rds"
  engine                 = "mysql"
  engine_version         = var.engine_version # e.g. "8.0.36"
  instance_class         = var.instance_class
  allocated_storage      = var.rds_storage
  storage_type           = "gp3"

  db_name                = var.db_name  # replace with your database name
  username               = var.db_username # e.g. "admin"
  password               = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id]

  multi_az               = false
  publicly_accessible    = true  # only if you really need public access

  backup_retention_period = var.environment == "prod" ? 7 : 0
  skip_final_snapshot     = var.environment != "prod"

  final_snapshot_identifier = var.environment == "prod" ? "${var.project_name}-${var.environment}-final-snapshot" : null

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds"
    Environment = var.environment
  }
}
