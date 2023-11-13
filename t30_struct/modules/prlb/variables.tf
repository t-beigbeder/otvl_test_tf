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

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
}

variable "instance_has_ssh" {
  description = "If ssh to EC2 instance enabled"
  type        = bool
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "instance_key_name" {
  description = "The key name for ssh to EC2 Instances"
  type        = string
}
