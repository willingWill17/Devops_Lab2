output "cluster_name" {
  description = "Amazon Web Service EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for Amazon Web Service EKS "
  value       = module.eks.cluster_endpoint
}

output "region" {
  description = "Amazon Web Service EKS Cluster region"
  value       = var.region
}

output "cluster_security_group_id" {
  description = "Security group ID for the Amazon Web Service EKS Cluster "
  value       = module.eks.cluster_security_group_id
}

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

# EC2 Outputs
output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Instance ID of bastion host"
  value       = aws_instance.bastion.id
}

output "app_server_private_ip" {
  description = "Private IP of application server"
  value       = aws_instance.app_server.private_ip
}

output "app_server_instance_id" {
  description = "Instance ID of application server"
  value       = aws_instance.app_server.id
}

# Security Group Outputs
output "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  value       = aws_security_group.bastion_sg.id
}

output "app_security_group_id" {
  description = "Security group ID for application servers"
  value       = aws_security_group.app_sg.id
}

output "alb_security_group_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

output "db_security_group_id" {
  description = "Security group ID for database"
  value       = aws_security_group.db_sg.id
}
