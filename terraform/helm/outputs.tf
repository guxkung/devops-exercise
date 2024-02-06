output "go_example_endpoint" {
    value = "http://${data.kubernetes_service.go_example.status.0.load_balancer.0.ingress.0.hostname}"
}
