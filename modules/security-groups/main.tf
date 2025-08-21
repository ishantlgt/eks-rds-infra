# RDS Security Group: allows inbound from EKS
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Allow traffic from EKS to MySQL RDS"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  }
}

# Allow MySQL from office IP 1
resource "aws_security_group_rule" "allow_mysql_ip_1" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["202.164.56.85/32"]
  security_group_id = aws_security_group.rds_sg.id
  description       = "Allow MySQL from office IP 202.164.56.85"
}

# Allow MySQL from office IP 2
resource "aws_security_group_rule" "allow_mysql_ip_2" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["202.164.56.82/32"]
  security_group_id = aws_security_group.rds_sg.id
  description       = "Allow MySQL from office IP 202.164.56.82"
}

# Allow EKS worker nodes to connect to MySQL RDS
resource "aws_security_group_rule" "allow_eks_to_rds" {
  type                     = "ingress"
  from_port                = 3306                # MySQL port
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = "sg-0ff4a8074c6d9b2fe"  # EKS worker node SG
  security_group_id        = aws_security_group.rds_sg.id
  description              = "Allow MySQL access from EKS worker nodes"
}
