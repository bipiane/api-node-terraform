variable "aws_region" {
  description = "The AWS Region that we will use to deploy the infrastructure (São Paulo)"
  type        = string
  default     = "sa-east-1"
}

variable "app_name" {
  description = "The application name will be used to tag and name the resources"
  type        = string
  default     = "node-api"
}

variable "server_port" {
  description = "The port that the server will use to handle HTTP requests"
  type        = number
  default     = 3001
}
