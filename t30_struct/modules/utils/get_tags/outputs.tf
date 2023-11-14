output "ready" {
  value       = merge(
    local.ctags, local.atags, local.etags, local.ptags
  )
  description = "Tags that apply to all resources ready to use"
}
