provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"  # Path to your kubeconfig file
    config_context = "kind-demo"  # Name of the Kubernetes context you want to use
  }
}
