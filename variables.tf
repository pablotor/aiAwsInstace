variable "instance_name" {
  description = "The full name of this instance"
  type        = string
}

variable "instance_name_short" {
  description = "Short name for tags and other related infrastructure"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "sa-east-1" # Brazil (São Paulo) region
}

variable "aws_profile" {
  description = "The AWS profile to deploy resources"
  type        = string
  default     = "default"
}

# variable "terraform_role_arn" {
#   description = "The AWS terraform role to deploy resources"
#   type        = string
# }

variable "availability_zone" {
  description = "The availability zone to deploy resources"
  type        = string
  default     = "sa-east-1a" # Availability zone in São Paulo
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-02cfee28b56653f5c" # Amazon Linux 2023 in sa-east-1
}

variable "public_key_path" {
  description = "The path to the public key for the key pair"
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key for SSH access"
  type        = string
}

variable "root_volume_size" {
  description = "The size of the root volume in GB"
  type        = number
  default     = 10
}

variable "user" {
  description = "The username for the main user"
  type        = string
}

variable "ollama_api_key" {
  description = "The api key to connect to ollama"
  type        = string
}

