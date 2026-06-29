module "argocd_extension" {
  source = "../../modules/argocd-extension"
  count  = var.enable_argocd_extension ? 1 : 0

  name       = "argocd"
  cluster_id = module.aks.id
  namespace  = var.argocd_namespace
  public_url = "https://${var.argocd_hostname}"
  application_namespaces = [
    var.argocd_namespace,
    "kairoai",
  ]
  redis_ha_enabled = var.argocd_redis_ha_enabled
  extra_configuration_settings = {
    "server.ingress.enabled" = "false"
  }
}
