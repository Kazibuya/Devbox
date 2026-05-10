variable "aws_region" {
  description = "north is cheaper"
  type = string
  default = "eu-north-1"
}

variable "instance_type" {
  description = "all in name"
  type = string
  default = "t3.small"
}

variable "project_name" {
  description = "all in name"
  type = string
}

variable "ip_host" {
  description = "all in name"
  type = string
}

variable "public_key_path" {
  description = "all in name"
  type = string
  default = "~/.ssh/devbox.pub"
}

variable "git_name" {
  description = "all in name"
  type = string
}

variable "git_email" {
  description = "all in name"
  type = string
}
