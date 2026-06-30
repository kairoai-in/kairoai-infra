terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_kubernetes_cluster_extension" "this" {
  name              = var.name
  cluster_id        = var.cluster_id
  extension_type    = "Microsoft.ArgoCD"
  release_train     = "Preview"
  release_namespace = var.namespace
  configuration_settings = merge(
    {
      "redis-ha.enabled"                        = tostring(var.redis_ha_enabled)
      "configs.params.application\\.namespaces" = join(",", var.application_namespaces)
      "configs.cm.url"                          = var.public_url
      "configs.rbac.policy\\.default"           = var.default_rbac_policy
    },
    var.extra_configuration_settings,
  )

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}
