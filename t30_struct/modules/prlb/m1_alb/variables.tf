# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "application_code" {
  description = "A unique code for the application"
  type        = string
}

variable "env_name" {
  description = "A unique environment name in this account"
  type        = string
}

variable "project_name" {
  description = "A unique project name in this account"
  type        = string
}

variable "resource_tags" {
  description = "Tags that apply to all resources"
  type        = list(object({
    key = string
    is_constant = bool
    constant = optional(string)
    is_application_code = bool
    is_env_name = bool
    is_project_name = bool
  }))
}

variable "vpc_is_default" {
  description = "Use default VPC, else only one VPC should be available"
  type        = bool
}

variable "subnets_name_filter" {
  description = "Name filter to get the subnets list to launch resources in"
  type        = string
}

variable "alb_domain_name" {
  description = "The DNS domain to reach the ALB (TLS certificate subject)"
  type        = string
}

variable "alb_ingress_cidrs" {
  description = "The list of CIDR ranges to enable as ingress on the ALB, if empty, all IPs are authorized"
  type = list(string)
}

variable "alb_ingress_port" {
  description = "The port to enable as ingress on the ALB"
  type = number
}

variable "alb_egress_port" {
  description = "The port to enable as egress on the ALB"
  type = number
}
