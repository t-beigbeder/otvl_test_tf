output "ubuntu_ami" {
  value       = module.prlb_ubuntu.ami
  description = "The ubuntu AMI"
}

output "amz2_ami" {
  value       = module.prlb_amz2.ami
  description = "The Amazon 2 AMI"
}
