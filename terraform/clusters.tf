#provision a ecs cluster 
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "main_cluster"                   # Naming the cluster
}
