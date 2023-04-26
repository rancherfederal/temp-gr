variable "ami_name" {
  description = "Name to give AMI"
  default     = ""
  type        = string
}

variable "aws_region" {
  description = "AWS region to build AMI in"
  default     = "us-gov-east-1"
  type        = string
}

variable "fips_enable" {
  description = "Enable FIPS mode on AMI"
  default     = false
  type        = bool
}

variable "instance_type" {
  description = "EC2 instance type to build from"
  default     = ""
  type        = string
}

variable "kms_key_id" {
  description = "Amazon KMS key to encrypt volumes with"
  default     = ""
  type        = string
}

variable "rhel_version" {
  description = "Major.Minor version of RHEL to pull base from"
  default     = ""
  type        = string
}

variable "rke2_version" {
  description = "Version of RKE2 to install"
  default     = ""
  type        = string
}

variable "stig_enable" {
  description = "Run RHEL8 STIG playbook from DISA"
  default     = true
  type        = bool
}

variable "subnet_id" {
  description = "AWS VPC subnet to build AMI in"
  default     = ""
  type        = string
}

variable "vpc_id" {
  description = "AWS VPC to build AMI in"
  default     = ""
  type        = string
}
