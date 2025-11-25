variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "eks-monitoring"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "monitoring-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# EKS Node Group Configuration
variable "node_group_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
  default     = ["t3.large"]
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in node group"
  type        = number
  default     = 3
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in node group"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in node group"
  type        = number
  default     = 6
}

variable "node_group_disk_size" {
  description = "Disk size for node group instances (GB)"
  type        = number
  default     = 100
}

# S3 Retention Policies
variable "loki_chunks_retention_days" {
  description = "Number of days to retain Loki chunks in S3 before transitioning"
  type        = number
  default     = 30
}

variable "loki_chunks_ia_days" {
  description = "Days before transitioning Loki chunks to Infrequent Access"
  type        = number
  default     = 90
}

variable "loki_chunks_glacier_days" {
  description = "Days before transitioning Loki chunks to Glacier"
  type        = number
  default     = 180
}

variable "loki_chunks_expiration_days" {
  description = "Days before expiring Loki chunks (0 = never expire)"
  type        = number
  default     = 365
}

variable "prometheus_retention_days" {
  description = "Number of days to retain Prometheus metrics in S3"
  type        = number
  default     = 30
}

variable "prometheus_ia_days" {
  description = "Days before transitioning Prometheus metrics to Infrequent Access"
  type        = number
  default     = 90
}

variable "prometheus_glacier_days" {
  description = "Days before transitioning Prometheus metrics to Glacier"
  type        = number
  default     = 180
}

variable "prometheus_expiration_days" {
  description = "Days before expiring Prometheus metrics (0 = never expire)"
  type        = number
  default     = 730
}

variable "enable_s3_versioning" {
  description = "Enable versioning on S3 buckets"
  type        = bool
  default     = true
}

# Cluster Add-ons
variable "enable_cluster_autoscaler" {
  description = "Enable cluster autoscaler"
  type        = bool
  default     = true
}

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver"
  type        = bool
  default     = true
}

variable "enable_alb_controller" {
  description = "Enable AWS Load Balancer Controller"
  type        = bool
  default     = true
}

# Monitoring Namespace
variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring components"
  type        = string
  default     = "monitoring"
}

# Additional Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}