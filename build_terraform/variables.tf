variable "instance_type" {
  default     = "t3.xlarge"
}

variable "associate_public_ip_address" {
  default     = false
}

variable "server_name" {
  default = "admin"
}

variable "env" {
  description = "The environment name, i.e. prod"
  default     = "dev"
}

variable "aws_key_pair" {
   default = "key-hmg"
}

variable "vpc" { 
  default = "vpc-name"
}

variable "ami" { 
  default = "ami-id" 
}

variable "aws_region" { 
  default = "sa-east-1" 
}

variable "subnet" { 
  default = "NET-PrivA" 
}

variable "availability_zones" {
  description = "AWS availability zones."
  default     = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
}

