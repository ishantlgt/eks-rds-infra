provider "aws" {
    region   = var.region
    profile  = "ishan"
}
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0.0" 
    }
  }
}
# create vpc

module "vpc" {

    source                              = "../modules/vpc"
    region                              = var.region
    project_name                        = var.project_name
    environment                         = var.environment
    vpc_cidr                            = var.vpc_cidr
    public_subnet_az1_cidr              = var.public_subnet_az1_cidr
    public_subnet_az2_cidr              = var.public_subnet_az2_cidr
    private_app_subnet_az1_cidr         = var.private_app_subnet_az1_cidr
    private_app_subnet_az2_cidr         = var.private_app_subnet_az2_cidr
    eks_cluster_name                    = var.eks_cluster_name
  
}

# EKS cluster setup in private subnet



module "security-groups" {
    source                              = "../modules/security-groups"
    project_name                        = var.project_name
    environment                         = var.environment
    vpc_id                              = module.vpc.vpc_id
    

}

module "rds" {

    source                              = "../modules/rds"
    project_name                        = var.project_name
    environment                         = var.environment
    private_app_subnet_ids              = module.vpc.private_app_subnet_ids
    instance_class                      = var.instance_class
    db_name                             = var.db_name
    db_username                         = var.db_username
    db_password                         = var.db_password
    rds_sg_id                           = module.security-groups.rds_sg_id
    vpc_id                              = module.vpc.vpc_id
    engine_version                      = var.engine_version
    rds_storage                         = var.rds_storage


}

module "ecr" {

    source                              = "../modules/ecr"
    project_name                        = var.project_name
    environment                         = var.environment
    images                              = var.images
}

module "secrets-manager" {

    source                              = "../modules/secrets-manager"
    project_name                        = var.project_name
    environment                         = var.environment
    secret_name                         = var.secret_name
    description                         = "Application environment variables for ${var.environment}"
     secret_values = {
    AWS_BUCKET_NAME        = var.AWS_BUCKET_NAME
    AWS_ACCESS_KEY_ID      = var.AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY  = var.AWS_SECRET_ACCESS_KEY
    AWS_REGION             = var.AWS_REGION
    UPLOAD_DIR             = var.UPLOAD_DIR
    COLLECTION_ID          = var.COLLECTION_ID

    MYSQL_USER             = var.MYSQL_USER
    MYSQL_PASSWORD         = var.MYSQL_PASSWORD
    MYSQL_DB               = var.MYSQL_DB
    DB_HOST                = var.DB_HOST
    PORT                   = var.PORT
    MYSQL_ROOT_PASSWORD    = var.MYSQL_ROOT_PASSWORD

    SMTP_API_KEY           = var.SMTP_API_KEY
    SMTP_PASSWORD          = var.SMTP_PASSWORD
    SMTP_FROM_EMAIL        = var.SMTP_FROM_EMAIL
    SMTP_SERVER            = var.SMTP_SERVER
    SMTP_PORT              = var.SMTP_PORT

    JWT_SECRET_KEY         = var.JWT_SECRET_KEY
    JWT_ALGORITHM          = var.JWT_ALGORITHM
  }

  
}

module "acm" {

    source                              = "../modules/acm"
    project_name                        = var.project_name
    environment                         = var.environment
    domain_name                         = var.domain_name
    san_names                           = var.san_names
    route53_zone_id                     = var.route53_zone_id


}

module "eks" {

    source                              =  "../modules/eks"
    region                              = var.region
    vpc_id                              = module.vpc.vpc_id
    private_app_subnet_az1_id           = module.vpc.private_app_subnet_az1_id
    eks_cluster_name                    = var.eks_cluster_name
    eks_version                         = var.eks_version
    private_app_subnet_az2_id           = module.vpc.private_app_subnet_az2_id
    environment                         = var.environment
    project_name                        = var.project_name
   # service_account_namespace           = var.service_account_namespace
   # service_account_name                = var.service_account_name
   

    

}