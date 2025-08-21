variable "region" {}
variable "project_name" {}
variable "vpc_cidr" {}
variable "public_subnet_az1_cidr" {}
variable "public_subnet_az2_cidr" {}
variable "private_app_subnet_az1_cidr" {}
variable "private_app_subnet_az2_cidr" {}
variable "eks_cluster_name" {}
variable "eks_version" {}
variable "environment" {}

##rds
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "engine_version" {}
variable "rds_storage" {}
variable "instance_class" {}

variable "images" {}

variable "secret_name" {}
variable "AWS_BUCKET_NAME" {}
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY"{}
variable "AWS_REGION" {}
variable "UPLOAD_DIR" {}
variable "COLLECTION_ID" {}

variable "MYSQL_USER" {}
variable "MYSQL_PASSWORD"{}
variable "MYSQL_DB" {}
variable "DB_HOST" {}
variable "PORT" {}
variable "MYSQL_ROOT_PASSWORD"{}

variable "SMTP_API_KEY" {}
variable "SMTP_PASSWORD"{}
variable "SMTP_FROM_EMAIL" {}
variable "SMTP_SERVER" {}
variable "SMTP_PORT" {}

variable "JWT_SECRET_KEY"{}
variable "JWT_ALGORITHM" {}

variable "domain_name" {}
variable "san_names" {}
variable "route53_zone_id" {}