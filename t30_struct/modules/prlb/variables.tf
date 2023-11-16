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

variable "kms_key_for_infra_arn" {
  description = "ARN of the KMS key created for infrastructure services"
  type = string
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

variable "ec2_mandatory_policy_name" {
  description = "The name or empty of a policy that applies to all EC2 instances"
  type        = string
}

variable "ami_name_regex" {
  description = "The name regex for filtering AMI of EC2 Instances to run (e.g. amzn2-ami-amd)"
  type        = string
}

variable "ami_owner" {
  description = "The owner name or empty for filtering AMI of Instances to run (e.g. 099720109477)"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
}

variable "ec2_mandatory_sg_name" {
  description = "The name or empty of a role that applies to all EC2 instances"
  type        = string
}

variable "asg_subnets_name_filter" {
  description = "Name filter to get the subnets list to launch ASG resources in"
  type        = string
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

variable "instance_user_data" {
  description = "User data to be passed to the instance"
  type        = string
  default     = null
}

variable "instance_ssh_key_name" {
  description = "The key name for ssh to EC2 Instances in the ASG or empty if no ssh"
  type        = string
  default     = ""
}
