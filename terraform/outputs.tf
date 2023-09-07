output "alb_dns_name" {
  description = "DNS of the Application Load Balancer"
  value       = "http://${aws_lb.app_alb.dns_name}"
}
