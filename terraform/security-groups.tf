# Security Groups Configuration

# Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project_name}-bastion-sg"
  description = "Security group for bastion host - SSH access"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-bastion-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Bastion - Ingress Rule: SSH from allowed IPs
resource "aws_security_group_rule" "bastion_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_cidr_blocks
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Allow SSH access from allowed CIDR blocks"
}

# Bastion - Egress Rule: Allow all outbound traffic
resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Allow all outbound traffic"
}

# Application Server Security Group
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for application servers"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-app-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# App - Ingress Rule: SSH from Bastion only
resource "aws_security_group_rule" "app_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.app_sg.id
  description              = "Allow SSH access from bastion host only"
}

# App - Ingress Rule: HTTP from ALB/VPC
resource "aws_security_group_rule" "app_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [module.vpc.vpc_cidr_block]
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow HTTP traffic from VPC"
}

# App - Ingress Rule: HTTPS from ALB/VPC
resource "aws_security_group_rule" "app_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [module.vpc.vpc_cidr_block]
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow HTTPS traffic from VPC"
}

# App - Ingress Rule: Application port (8080)
resource "aws_security_group_rule" "app_custom_port_ingress" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [module.vpc.vpc_cidr_block]
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow application traffic on port 8080 from VPC"
}

# App - Egress Rule: Allow all outbound traffic
resource "aws_security_group_rule" "app_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow all outbound traffic"
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ALB - Ingress Rule: HTTP from Internet
resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP traffic from internet"
}

# ALB - Ingress Rule: HTTPS from Internet
resource "aws_security_group_rule" "alb_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTPS traffic from internet"
}

# ALB - Egress Rule: To App servers
resource "aws_security_group_rule" "alb_to_app_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.alb_sg.id
  description              = "Allow traffic to application servers"
}

# Database Security Group
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for database instances"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-db-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# DB - Ingress Rule: MySQL/Aurora from App servers
resource "aws_security_group_rule" "db_mysql_from_app" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.db_sg.id
  description              = "Allow MySQL traffic from application servers"
}

# DB - Ingress Rule: PostgreSQL from App servers
resource "aws_security_group_rule" "db_postgres_from_app" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.db_sg.id
  description              = "Allow PostgreSQL traffic from application servers"
}

# DB - Egress Rule: Allow all outbound traffic
resource "aws_security_group_rule" "db_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_sg.id
  description       = "Allow all outbound traffic"
}

