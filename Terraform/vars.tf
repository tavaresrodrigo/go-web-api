variable "name" {
  default = "go-web-api"
}

variable "container_name" {
  default = "gowebapi"
} 

variable "container_port" {
  default = 8080
}

variable "region" {
  default = "eu-west-1"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
    tags = { 
        app = var.name
        environment = "Development"
        last_modified = timestamp()
        creator = "tavarodri"
    }
}
