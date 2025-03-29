variable "ssh_key_name"{ 
  description = "The name of the SSH key pair to use for EKS instance"
  type = string
  default = "eks-cluster-key"
}