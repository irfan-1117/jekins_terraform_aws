# variables.tf

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "ami_id" {
  type    = string
  default = "ami-07d9b9ddc6cd8dd30"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "bucket" {
  type = string
  default = "mybucketforthedemo1101"
}

variable "key" {
  type = string
  default = "terraform.tfstate"
  
}