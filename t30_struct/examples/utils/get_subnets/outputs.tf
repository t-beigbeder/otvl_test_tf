output "subnets" {
  value       = module.prlb_subnets_sub.list
  description = "The filtered subnets"
}

output "subnets_a" {
  value       = module.prlb_subnets_a.list
  description = "The filtered subnets a"
}

output "byid" {
  value       = module.prlb_subnets_sub.byid
  description = "The filtered subnets map by id"
}

output "byname" {
  value       = module.prlb_subnets_sub.byname
  description = "The filtered subnets map by name"
}

output "ids" {
  value       = module.prlb_subnets_sub.ids
  description = "The filtered subnets ids"
}
