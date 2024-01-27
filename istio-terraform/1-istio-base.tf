# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install demo-istio-base-release -n istio-system --create-namespace istio/base --set global.istioNamespace=istio-system
resource "helm_release" "istio_base" {
  name = "demo-istio-base-release"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = "istio-system"
  create_namespace = true

  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }
}
