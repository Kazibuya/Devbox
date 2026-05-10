output "ssh_command" {
  description = "Command SSH to coonect"
  value = "ssh ubuntu@${aws_instance.dev.public_ip}"
}
