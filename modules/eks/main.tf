resource "aws_eks_cluster" "main_eks" {
    name = "main_eks_${var.nome_progetto}"
    vpc_config {
        subnet_ids = [module.vpc.subnet_ids]
      
    }
  role_arn = aws_iam_role.eks_cluster_role.arn
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
