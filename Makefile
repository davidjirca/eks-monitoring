.PHONY: help init plan apply destroy validate fmt clean outputs verify-aws kubectl-config

# Variables
CLUSTER_NAME ?= $(shell terraform output -raw cluster_name 2>/dev/null || echo "monitoring-cluster")
REGION ?= $(shell terraform output -raw region 2>/dev/null || echo "us-east-1")

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)EKS Monitoring Infrastructure - Terraform Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

verify-aws: ## Verify AWS credentials and access
	@echo "$(BLUE)Verifying AWS credentials...$(NC)"
	@aws sts get-caller-identity
	@echo "$(GREEN)✓ AWS credentials verified$(NC)"

init: ## Initialize Terraform
	@echo "$(BLUE)Initializing Terraform...$(NC)"
	@terraform init
	@echo "$(GREEN)✓ Terraform initialized$(NC)"

validate: ## Validate Terraform configuration
	@echo "$(BLUE)Validating Terraform configuration...$(NC)"
	@terraform validate
	@echo "$(GREEN)✓ Configuration is valid$(NC)"

fmt: ## Format Terraform files
	@echo "$(BLUE)Formatting Terraform files...$(NC)"
	@terraform fmt -recursive
	@echo "$(GREEN)✓ Files formatted$(NC)"

plan: ## Create Terraform plan
	@echo "$(BLUE)Creating Terraform plan...$(NC)"
	@terraform plan -out=tfplan
	@echo "$(GREEN)✓ Plan created: tfplan$(NC)"

apply: ## Apply Terraform plan
	@echo "$(YELLOW)This will create real AWS resources that incur costs!$(NC)"
	@read -p "Are you sure you want to apply? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(BLUE)Applying Terraform plan...$(NC)"; \
		terraform apply tfplan; \
		echo "$(GREEN)✓ Infrastructure deployed$(NC)"; \
		$(MAKE) outputs; \
	else \
		echo "$(YELLOW)Apply cancelled$(NC)"; \
	fi

apply-auto: plan ## Apply plan automatically (use with caution!)
	@echo "$(BLUE)Applying Terraform plan automatically...$(NC)"
	@terraform apply tfplan
	@echo "$(GREEN)✓ Infrastructure deployed$(NC)"
	@$(MAKE) outputs

outputs: ## Display Terraform outputs
	@echo "$(BLUE)Terraform Outputs:$(NC)"
	@terraform output

outputs-json: ## Save outputs to JSON file
	@echo "$(BLUE)Saving outputs to terraform-outputs.json...$(NC)"
	@terraform output -json > terraform-outputs.json
	@echo "$(GREEN)✓ Outputs saved$(NC)"

kubectl-config: ## Configure kubectl for EKS cluster
	@echo "$(BLUE)Configuring kubectl...$(NC)"
	@aws eks update-kubeconfig --name $(CLUSTER_NAME) --region $(REGION)
	@echo "$(GREEN)✓ kubectl configured$(NC)"
	@kubectl get nodes

verify-cluster: kubectl-config ## Verify cluster is healthy
	@echo "$(BLUE)Verifying cluster health...$(NC)"
	@echo "\n$(BLUE)Nodes:$(NC)"
	@kubectl get nodes
	@echo "\n$(BLUE)Namespaces:$(NC)"
	@kubectl get ns
	@echo "\n$(BLUE)kube-system pods:$(NC)"
	@kubectl get pods -n kube-system
	@echo "\n$(BLUE)Monitoring namespace:$(NC)"
	@kubectl get all -n monitoring
	@echo "$(GREEN)✓ Cluster verification complete$(NC)"

verify-alb: ## Verify ALB Controller
	@echo "$(BLUE)Checking ALB Controller...$(NC)"
	@kubectl get deployment -n kube-system aws-load-balancer-controller
	@kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
	@echo "$(GREEN)✓ ALB Controller verification complete$(NC)"

verify-s3: ## Verify S3 buckets
	@echo "$(BLUE)Listing S3 buckets...$(NC)"
	@aws s3 ls | grep eks-monitoring || echo "No matching buckets found"

show-costs: ## Show estimated monthly costs
	@echo "$(BLUE)Estimated Monthly Costs:$(NC)"
	@echo "  EKS Control Plane:     $$73.00"
	@echo "  NAT Gateways (3 AZs):  $$96.00"
	@echo "  EC2 Nodes (3x t3.large): ~$$190.00"
	@echo "  EBS Volumes (300GB):   ~$$30.00"
	@echo "  VPC Endpoints:         ~$$20.00"
	@echo "  $(YELLOW)Baseline Total: ~$$400-450/month$(NC)"
	@echo ""
	@echo "  $(YELLOW)+ S3 storage costs (variable)$(NC)"
	@echo "  $(YELLOW)+ Data transfer costs (variable)$(NC)"

destroy: ## Destroy all infrastructure
	@echo "$(YELLOW)WARNING: This will destroy ALL resources!$(NC)"
	@echo "$(YELLOW)Make sure to backup any important data first!$(NC)"
	@read -p "Type 'destroy' to confirm: " confirm; \
	if [ "$$confirm" = "destroy" ]; then \
		echo "$(BLUE)Emptying S3 buckets...$(NC)"; \
		$(MAKE) empty-s3; \
		echo "$(BLUE)Destroying infrastructure...$(NC)"; \
		terraform destroy; \
		echo "$(GREEN)✓ Infrastructure destroyed$(NC)"; \
	else \
		echo "$(YELLOW)Destroy cancelled$(NC)"; \
	fi

empty-s3: ## Empty all S3 buckets
	@echo "$(BLUE)Emptying S3 buckets...$(NC)"
	@LOKI_CHUNKS=$$(terraform output -raw loki_chunks_bucket 2>/dev/null); \
	LOKI_RULER=$$(terraform output -raw loki_ruler_bucket 2>/dev/null); \
	PROMETHEUS=$$(terraform output -raw prometheus_bucket 2>/dev/null); \
	TEMPO=$$(terraform output -raw tempo_bucket 2>/dev/null); \
	if [ -n "$$LOKI_CHUNKS" ]; then aws s3 rm s3://$$LOKI_CHUNKS --recursive; fi; \
	if [ -n "$$LOKI_RULER" ]; then aws s3 rm s3://$$LOKI_RULER --recursive; fi; \
	if [ -n "$$PROMETHEUS" ]; then aws s3 rm s3://$$PROMETHEUS --recursive; fi; \
	if [ -n "$$TEMPO" ]; then aws s3 rm s3://$$TEMPO --recursive; fi
	@echo "$(GREEN)✓ S3 buckets emptied$(NC)"

clean: ## Clean up local files
	@echo "$(BLUE)Cleaning up local files...$(NC)"
	@rm -f tfplan
	@rm -f terraform-outputs.json
	@rm -rf .terraform/
	@rm -f .terraform.lock.hcl
	@echo "$(GREEN)✓ Local files cleaned$(NC)"

graph: ## Generate dependency graph
	@echo "$(BLUE)Generating dependency graph...$(NC)"
	@terraform graph | dot -Tpng > graph.png
	@echo "$(GREEN)✓ Graph saved to graph.png$(NC)"

cost-estimate: ## Show detailed cost estimate (requires infracost)
	@command -v infracost >/dev/null 2>&1 || { \
		echo "$(YELLOW)infracost not installed. Install from: https://www.infracost.io/docs/$(NC)"; \
		exit 1; \
	}
	@echo "$(BLUE)Generating cost estimate with infracost...$(NC)"
	@infracost breakdown --path .

setup: ## Complete setup (init, plan, apply)
	@$(MAKE) verify-aws
	@$(MAKE) init
	@$(MAKE) validate
	@$(MAKE) fmt
	@$(MAKE) plan
	@$(MAKE) apply

complete-verify: verify-cluster verify-alb verify-s3 ## Run all verification checks
	@echo "$(GREEN)✓ All verifications complete!$(NC)"

# Development helpers
dev-apply: ## Quick apply for development (skips confirmation)
	@terraform apply -auto-approve

dev-destroy: ## Quick destroy for development (skips confirmation) 
	@$(MAKE) empty-s3
	@terraform destroy -auto-approve