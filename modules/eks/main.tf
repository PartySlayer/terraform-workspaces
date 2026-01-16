resource "aws_eks_cluster" "main_eks" {
  name = "main_eks_${var.nome_progetto}"
  vpc_config {
    subnet_ids = var.subnet_ids

  }

  role_arn = aws_iam_role.eks_cluster_role.arn

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# LOGICA IAM ROLE

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.nome_progetto}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags # Applica gli stessi tag se vuoi
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# DATA PLANE

# Ruolo IAM per i Nodi
resource "aws_iam_role" "eks_nodes" {
  name = "${var.nome_progetto}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
    Version = "2012-10-17"
  })

  tags = var.tags
}

# Policy e relative associazioni necessarie per i Nodi (CNI, WorkerNode, Registry)
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# Il Node Group vero e proprio
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main_eks.name
  node_group_name = "${var.nome_progetto}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.subnet_ids # stesse subnet private del cluster

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"] 
  capacity_type  = "ON_DEMAND"   

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_registry_policy,
  ]

  tags = var.tags
}