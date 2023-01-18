variable "project_name" {
  description = "Some prefix to namespace the resources for the project if shipping a server binary."
  type = string
}

variable "docker_image" {
    description = "The docker image to use for the server."
  type = string
}

variable "container_port" {
    description = "The port the container will listen on."
  type = number
}

variable "healthcheck_port" {
    description = "The port the healthcheck will listen on."
    type = number
}

variable "healthcheck_path" {
    description = "The path the healthcheck will listen on."
    type = string
}