output "policy_definition_id" {
  description = "The ID of the created policy definition"
  value       = azurerm_policy_definition.custom_policy.id
}

output "policy_assignment_name" {
  description = "The name of the policy assignment"
  value       = azurerm_resource_group_policy_assignment.custom_assignment.name
}

output "resource_group_scope" {
  description = "The scope where the policy is assigned"
  value       = azurerm_resource_group.policy_rg.id
}
