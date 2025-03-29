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