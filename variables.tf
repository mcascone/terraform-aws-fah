variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}

variable "ubuntu_ami" {
  description = "the amz ubuntu micro ami"
  default  = "ami-0fc20dd1da406780b"
}