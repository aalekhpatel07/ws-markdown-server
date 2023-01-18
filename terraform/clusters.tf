
// Straightforward cluster definition. Might not need any more clusters in the future.
resource "aws_ecs_cluster" "my_default_cluster" {
    name = var.project_name   
}