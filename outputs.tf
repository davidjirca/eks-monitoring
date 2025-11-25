# EKS Cluster Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

# Region
output "region" {
  description = "AWS region"
  value       = var.region
}

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

# OIDC Provider Output
output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC Provider"
  value       = aws_iam_openid_connect_provider.eks.url
}

# IAM Role ARNs for IRSA (use these in Helm values)
output "loki_s3_role_arn" {
  description = "IAM role ARN for Loki to access S3"
  value       = aws_iam_role.loki_s3.arn
}

output "prometheus_s3_role_arn" {
  description = "IAM role ARN for Prometheus/Mimir to access S3"
  value       = aws_iam_role.prometheus_s3.arn
}

output "grafana_role_arn" {
  description = "IAM role ARN for Grafana (CloudWatch access)"
  value       = aws_iam_role.grafana.arn
}

output "alb_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = var.enable_alb_controller ? aws_iam_role.alb_controller[0].arn : null
}

output "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for EBS CSI Driver"
  value       = var.enable_ebs_csi_driver ? aws_iam_role.ebs_csi_driver[0].arn : null
}

output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for Cluster Autoscaler"
  value       = var.enable_cluster_autoscaler ? aws_iam_role.cluster_autoscaler[0].arn : null
}

# S3 Bucket Outputs
output "loki_chunks_bucket" {
  description = "S3 bucket name for Loki chunks"
  value       = aws_s3_bucket.loki_chunks.id
}

output "loki_chunks_bucket_arn" {
  description = "S3 bucket ARN for Loki chunks"
  value       = aws_s3_bucket.loki_chunks.arn
}

output "loki_ruler_bucket" {
  description = "S3 bucket name for Loki ruler"
  value       = aws_s3_bucket.loki_ruler.id
}

output "loki_ruler_bucket_arn" {
  description = "S3 bucket ARN for Loki ruler"
  value       = aws_s3_bucket.loki_ruler.arn
}

output "prometheus_bucket" {
  description = "S3 bucket name for Prometheus long-term storage"
  value       = aws_s3_bucket.prometheus_storage.id
}

output "prometheus_bucket_arn" {
  description = "S3 bucket ARN for Prometheus long-term storage"
  value       = aws_s3_bucket.prometheus_storage.arn
}

output "tempo_bucket" {
  description = "S3 bucket name for Tempo traces (future use)"
  value       = aws_s3_bucket.tempo_storage.id
}

output "tempo_bucket_arn" {
  description = "S3 bucket ARN for Tempo traces"
  value       = aws_s3_bucket.tempo_storage.arn
}

# Monitoring Namespace
output "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring components"
  value       = var.monitoring_namespace
}

# Node Group Outputs
output "node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.main.id
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.main.status
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = aws_security_group.eks_nodes.id
}

# Helpful kubectl and Helm commands
output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.region}"
}

output "helm_values_snippets" {
  description = "Snippets for Helm values files"
  value = {
    loki_irsa = {
      serviceAccount = {
        create = true
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.loki_s3.arn
        }
      }
    }
    prometheus_irsa = {
      serviceAccount = {
        create = true
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.prometheus_s3.arn
        }
      }
    }
    grafana_irsa = {
      serviceAccount = {
        create = true
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.grafana.arn
        }
      }
    }
  }
}

# Summary output
output "cluster_summary" {
  description = "Summary of key cluster information"
  value = {
    cluster_name         = aws_eks_cluster.main.name
    cluster_endpoint     = aws_eks_cluster.main.endpoint
    cluster_version      = aws_eks_cluster.main.version
    region               = var.region
    vpc_id               = aws_vpc.main.id
    monitoring_namespace = var.monitoring_namespace
  }
}

output "s3_buckets_summary" {
  description = "Summary of S3 buckets created"
  value = {
    loki_chunks = aws_s3_bucket.loki_chunks.id
    loki_ruler  = aws_s3_bucket.loki_ruler.id
    prometheus  = aws_s3_bucket.prometheus_storage.id
    tempo       = aws_s3_bucket.tempo_storage.id
  }
}

output "irsa_roles_summary" {
  description = "Summary of IRSA roles created"
  value = {
    loki               = aws_iam_role.loki_s3.arn
    prometheus         = aws_iam_role.prometheus_s3.arn
    grafana            = aws_iam_role.grafana.arn
    alb_controller     = var.enable_alb_controller ? aws_iam_role.alb_controller[0].arn : "not enabled"
    ebs_csi_driver     = var.enable_ebs_csi_driver ? aws_iam_role.ebs_csi_driver[0].arn : "not enabled"
    cluster_autoscaler = var.enable_cluster_autoscaler ? aws_iam_role.cluster_autoscaler[0].arn : "not enabled"
  }
}