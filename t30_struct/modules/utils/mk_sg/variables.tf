variable "name" {
  description = "The name of the security group"
  type        = string
}

variable "description" {
  description = "The description of the security group, may be null"
  type        = string
  default = null
}

variable "tags" {
  description = "The tags to apply the security group, may be empty"
  type        = map(string)
  default = {}
}

variable "egress_rule" {
  description = "A single egress rule, may be null in that case no outbound traffic"
  type        = object({
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string)
    ipv6_cidr_blocks = list(string)
    source_security_group_id = list(string)
  })
  default = null
}

variable "egress_allow_all" {
  description = "Overrides egress attribute to allow all outbound traffic"
  type        = bool
  default = false
}

variable "ingress_rules" {
  description = "A list of ingress rule"
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string)
    ipv6_cidr_blocks = list(string)
    source_security_group_id = list(string)
  }))
  default = []
}
