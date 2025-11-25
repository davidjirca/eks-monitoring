# AWS Load Balancer Controller
# This manages ALB creation for Kubernetes Ingress resources

# Create kube-system namespace service account for ALB controller
resource "kubernetes_service_account" "alb_controller" {
  count = var.enable_alb_controller ? 1 : 0

  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller[0].arn
    }
  }

  depends_on = [aws_eks_cluster.main]
}

# Install AWS Load Balancer Controller using Helm
resource "helm_release" "alb_controller" {
  count = var.enable_alb_controller ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.6.2" # Check for latest version

  set {
    name  = "clusterName"
    value = aws_eks_cluster.main.name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller[0].metadata[0].name
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }

  # Enable shield, WAF, and other features
  set {
    name  = "enableShield"
    value = "false" # Set to true if you use AWS Shield
  }

  set {
    name  = "enableWaf"
    value = "false" # Set to true if you use AWS WAF
  }

  set {
    name  = "enableWafv2"
    value = "false" # Set to true if you use AWS WAFv2
  }

  # Resource settings
  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "resources.limits.memory"
    value = "512Mi"
  }

  # Replica count
  set {
    name  = "replicaCount"
    value = "2"
  }

  depends_on = [
    kubernetes_service_account.alb_controller,
    aws_eks_node_group.main,
  ]
}

# Note: After ALB controller is installed, you can create Ingress resources like this:
#
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: grafana
#   namespace: monitoring
#   annotations:
#     alb.ingress.kubernetes.io/scheme: internet-facing
#     alb.ingress.kubernetes.io/target-type: ip
#     alb.ingress.kubernetes.io/healthcheck-path: /api/health
#     alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
#     alb.ingress.kubernetes.io/ssl-redirect: '443'
#     # For HTTPS, add your certificate ARN:
#     # alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:region:account:certificate/xxx
# spec:
#   ingressClassName: alb
#   rules:
#     - host: grafana.yourdomain.com
#       http:
#         paths:
#           - path: /
#             pathType: Prefix
#             backend:
#               service:
#                 name: grafana
#                 port:
#                   number: 80