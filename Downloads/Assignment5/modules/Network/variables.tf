variable "vpc_name" {
  description = "Name of the VPC"
  default     = "ninja-vpc-01"
}

variable "public_subnet_names" {
  description = "List of public subnet names"
  type        = list(string)
  default     = ["ninja-pub-sub-01", "ninja-pub-sub-02"]
}

variable "availability_zones" {
  description = "AZs"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "private_subnet_names" {
  description = "List of private subnet names"
  type        = list(string)
  default     = ["ninja-priv-sub-01", "ninja-priv-sub-02"]
}

variable "instance_ami" {
  description = "AMI ID for instances"
  type        = string
  default            =  "ami-0f5ee92e2d63afc18"
}

variable "key" {
  description = "SSH key"
  type        = string
  default     = "my _key"
}

variable "instance" {
  description = "Instance type to be used"
  type        = string
  default     = "t2.micro"
}

variable "igw_name" {
  description = "igw name"
  type        = string
  default     = "ninja-igw-01"
}
