resource "aws_ecs_task_definition" "markdown_server" {
    family = "markdown-server"
    container_definitions = <<DEFINITION
    [
        {
            "name": "markdown-server",
            "image": "aalekhpatel07/ws-markdown-server:1.0.2",
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 9003,
                    "hostPort": 9003
                },
                {
                    "containerPort": 9004,
                    "hostPort": 9004
                },
                {
                    "containerPort": 9005,
                    "hostPort": 9005
                }
            ],
            "memory": 512,
            "cpu": 256
        }
    ]
    DEFINITION

    requires_compatibilities = [ "FARGATE" ]
    network_mode = "awsvpc"
    memory = 512
    cpu = 256
    execution_role_arn = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}