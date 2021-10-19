variable instance_count {
  description = "Number of EC2 instances to deploy"
  type        = number
}

variable "name" {
  description = "An identifier for the EC2 instance"
}

variable instance_type {
  description = "Type of EC2 instance to use"
  type        = string
}

variable subnet_ids {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
}

variable security_group_ids {
  description = "Security group IDs for EC2 instances"
  type        = list(string)
}

variable project_name {
  description = "Name of the project"
  type        = string
}

variable environment {
  description = "Name of the environment"
  type        = string
}

variable data_disk_size {
  type        = number
  description = "Size, in GB, of data disk(s)"
  default     = 0
}

variable "user_data_template" {
  description = "The user_data template to use on cloud init"
  default = "default.yml.tpl"
}

variable "key_pair" {
  description = "The KeyPair used to connect to EC2 instances"
}

variable "internal_dns_zone_id" {
  description = "The internal DNS zone to set a record against"
}

variable "efs_file_system_id" {
  description = "The EFS Filesystem which we will mount for purposes of Ansilble Inventory"
}