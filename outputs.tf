output "eks_vpc_id"{
  value= aws_vpc.eks_cluster_vpc.id
}

output "eks_vpc_subnet_id"{
  value = aws_subnet.eks_cluster_subnets[*].id
}

output "eks_cluster_id"{
  value = aws_eks_cluster.gitops_cluster.id
}

output "eks_node_group_id"{
  value = aws_eks_node_group.gitops_cluster_node_group.id
}