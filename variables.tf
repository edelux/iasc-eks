
variable "environment" { #REQUIRED
  description = "Environment Name (dev, qa, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^(dev|aq|stag|pr[do])[a-z0-9]{0,9}$", var.environment))
    error_message = "The environment name must start with 'dev', 'pro', or 'prd', followed by up to 9 lowercase letters or numbers, with a total length between 3 and 12 characters."
  }

  validation {
    condition     = terraform.workspace == var.environment
    error_message = "Invalid workspace: The active workspace '${terraform.workspace}' does not match the specified environment '${var.environment}'."
  }
}

## EKS
variable "admin_allowed_ips" {
  type    = list(string)
  default = []
}

variable "cluster_version" {
  description = "Cluster version"
  type        = string
  default     = "1.32"
}

variable "cluster_addons" {
  description = "Addons and versions list"
  type        = map(string)
  default     = {}
}

variable "max_nodes" {
  description = "Maximun nodes at cluster"
  type        = number
  default     = 2
}

variable "min_nodes" {
  description = "Mininum nodes at cluster"
  type        = number
  default     = 2
}

variable "desired_nodes" {
  description = "Desired nodes at cluster"
  type        = number
  default     = 2
}
