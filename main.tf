provider "aws"{
  region = "us-east-1"
}

resource "aws_vpc" "eks_cluster_vpc"{
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "eks-cluster-vpc"
    environment = "practice"
  }
}

resource "aws_subnet" "eks_cluster_subnets"{
  count =2
  vpc_id = aws_vpc.eks_cluster_vpc.id
  cidr_block = cidrsubnet(aws_vpc.eks_cluster_vpc.cidr_block, 8, count.index) 
  #cidr subnet dynamically creates a subnet within the vpc range.
  #The value 8 is to add 8 bits to subnet mask out of like 10.0.0.0/8.
  #Count.index for referencing the two subnets.
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true #This ensures that the instances launching in these subnets gets a public ip.

  tags = {
    name = "eks-cluster-subnets"
    environment = "practice"
  } 
}

resource "aws_internet_gateway" "eks_cluster_gateway"{
  vpc_id = aws_vpc.eks_cluster_vpc.id
  tags = {
    name = "eks_cluster_intenet_gateway"
    environment = "practice"
  }
}

resource "aws_route_table" "eks_cluster_route_table"{
  vpc_id = aws_vpc.eks_cluster_vpc.id
  route {
    cidr_block = "0.0.0.0/0" #This forwards all the non local traffic(Apart from the vpc range) to the internet gatway.
    gateway_id = aws_internet_gateway.eks_cluster_gateway.id
  }
  tags = {
    name = "eks_cluster_intenet_gateway"
    environment = "practice"
  }
}

resource "aws_route_table_association" "eks_table_association"{
  count = 2
  subnet_id = aws_subnet.eks_cluster_subnets[count.index].id
  route_table_id = aws_route_table.eks_cluster_route_table.id
}

resource "aws_security_group" "eks_cluster_sg"{
  vpc_id = aws_vpc.eks_cluster_vpc.id
  egress {
    from_port = 0 #Applies to all ports. 
    to_port = 0 #Applies to all ports. 
    protocol = -1 #Applies to all protocols
    cidr_blocks = ["0.0.0.0/0"] #Allows traffic to any IP address 
  }
  tags = {
    name = "eks_cluster_intenet_gateway"
    environment = "practice"
  }  
}

resource "aws_security_group" "eks_node_sg"{
  vpc_id = aws_vpc.eks_cluster_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "eks_cluster_intenet_gateway"
    environment = "practice"
  }
}

resource "aws_eks_cluster" "gitops_cluster"{
  name = "gitops_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config{
    subnet_ids = aws_subnet.eks_cluster_subnets[*].id
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }
}

resource "aws_eks_node_group" "gitops_cluster_node_group"{
  cluster_name = aws_eks_cluster.gitops_cluster.name
  node_group_name = "gitops_cluster_node_group"
  node_role_arn = aws_iam_role.eks_node_group_role.arn
  subnet_ids = aws_subnet.eks_cluster_subnets[*].id
  instance_types = ["t2.medium"]

  scaling_config{
    desired_size = 3
    max_size = 3
    min_size = 3
  }

  remote_access{
    ec2_ssh_key = var.ssh_key_name
    source_security_group_ids = [aws_security_group.eks_node_sg.id]
  }
}

resource "aws_iam_role" "eks_cluster_role"{
  name = "eks_cluster_role"


  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
        "eks.amazonaws.com",
        "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
#principal specfies that only the ec2 and eks service can only use this role.
}


resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy_attachment"{
  role = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
# AmazonEKSWorkerNodePolicy
# Purpose:
# Grants permissions for EC2 instances (worker nodes) to join the EKS cluster and communicate with the EKS control plane.
# Key actions allowed:
# Register/deregister nodes with the cluster
# Describe cluster resources

resource "aws_iam_role_policy_attachment" "eks_node_group_role_policy_attachment"{
  role = aws_iam_role.eks_node_group_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# AmazonEKS_CNI_Policy
# Purpose:
# Allows the worker nodes to manage networking for Kubernetes pods using the Amazon VPC CNI plugin.
# Key actions allowed:
# Create, describe, and delete network interfaces (ENIs)
# Assign and unassign IP addresses
resource "aws_iam_role_policy_attachment" "eks_node_group_role_cni_policy_attachment"{
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# AmazonEC2ContainerRegistryReadOnly
# Purpose:
# Allows the worker nodes to pull (download) container images from Amazon Elastic Container Registry (ECR).
# Key actions allowed:
# Read-only access to ECR repositories (pull images, but not push)
resource "aws_iam_role_policy_attachment" "eks_node-group_role_register_policy_attachment"{
  role = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

