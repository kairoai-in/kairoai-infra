package terraform.kairoai

required_tags := {"application", "environment", "managed_by", "owner", "cost_center"}

deny[msg] {
  rc := input.resource_changes[_]
  rc.mode == "managed"
  rc.change.actions[_] != "delete"
  tags := object.get(rc.change.after, "tags", {})
  missing := required_tags - {tag | tags[tag]}
  count(missing) > 0
  msg := sprintf("%s is missing required tags: %v", [rc.address, sort(missing)])
}

deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "azurerm_key_vault"
  rc.change.actions[_] != "delete"
  env := object.get(object.get(rc.change.after, "tags", {}), "environment", "")
  env == "prod"
  not rc.change.after.purge_protection_enabled
  msg := sprintf("%s must enable purge protection in prod", [rc.address])
}

deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "azurerm_key_vault"
  rc.change.actions[_] != "delete"
  env := object.get(object.get(rc.change.after, "tags", {}), "environment", "")
  env == "prod-dr"
  not rc.change.after.purge_protection_enabled
  msg := sprintf("%s must enable purge protection in prod-dr", [rc.address])
}

deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "azurerm_kubernetes_cluster_node_pool"
  rc.change.actions[_] != "delete"
  not rc.change.after.enable_auto_scaling
  msg := sprintf("%s must enable AKS cluster autoscaler", [rc.address])
}

deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "azurerm_application_gateway"
  rc.change.actions[_] != "delete"
  not waf_v2_gateway(rc.change.after)
  msg := sprintf("%s must use Application Gateway WAF_v2", [rc.address])
}

deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "azurerm_cdn_frontdoor_profile"
  rc.change.actions[_] != "delete"
  rc.change.after.sku_name != "Premium_AzureFrontDoor"
  msg := sprintf("%s must use Azure Front Door Premium", [rc.address])
}

deny[msg] {
  rc := input.resource_changes[_]
  rc.type == "azurerm_servicebus_namespace"
  rc.change.actions[_] != "delete"
  env := object.get(object.get(rc.change.after, "tags", {}), "environment", "")
  env == "prod"
  rc.change.after.sku != "Premium"
  msg := sprintf("%s must use Service Bus Premium in prod", [rc.address])
}

waf_v2_gateway(after) {
  sku := after.sku[_]
  sku.name == "WAF_v2"
  sku.tier == "WAF_v2"
}
