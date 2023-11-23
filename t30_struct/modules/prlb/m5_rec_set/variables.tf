variable "hosted_zone_name" {
  description = "The DNS domain of the hosted zone of the account"
  type        = string
}

variable "hosted_zone_is_private" {
  description = "Private status of the hosted zone of the account"
  type        = bool
}

variable "alb_domain_name" {
  description = "The DNS domain to reach the ALB (TLS certificate subject)"
  type        = string
}

variable "alb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)"
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the load balancer"
  type        = string
}
