resource "aws_ecs_service" "markdown_server" {
    name = "markdown-server"
    cluster = "${aws_ecs_cluster.my_default_cluster.id}"
    task_definition = "${aws_ecs_task_definition.markdown_server.arn}"
    launch_type = "FARGATE"
    desired_count = 3

    load_balancer {
        target_group_arn = "${aws_lb_target_group.markdown_server_target_group.arn}"
        container_name = "${aws_ecs_task_definition.markdown_server.family}"
        container_port = 9003
    }

    network_configuration {
        subnets = [
            "${aws_default_subnet.default_subnet_a.id}", 
            "${aws_default_subnet.default_subnet_b.id}", 
            "${aws_default_subnet.default_subnet_c.id}"
        ]
        security_groups = [
            "${aws_security_group.load_balancer_security_group.id}",
            "${aws_security_group.markdown_server_security_group.id}"
        ]
        assign_public_ip = true
    }
}
