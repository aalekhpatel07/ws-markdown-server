resource "aws_alb" "markdown_server_load_balancer" {
    name = "markdown-server-load-balancer"
    load_balancer_type = "application"

    subnets = [
        "${aws_default_subnet.default_subnet_a.id}", 
        "${aws_default_subnet.default_subnet_b.id}", 
        "${aws_default_subnet.default_subnet_c.id}"
    ]

    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_security_group" "load_balancer_security_group" {
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_security_group" "markdown_server_security_group" {
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb_target_group" "markdown_server_target_group" {
    name = "markdown-server-target-group"
    port = 80
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = "${aws_default_vpc.default_vpc.id}"
    health_check {
        path = "/"
        interval = 15
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
        port = 9005
        matcher = "200,301,302"
    }
}

resource "aws_lb_listener" "markdown_server_listener" {
    load_balancer_arn = "${aws_alb.markdown_server_load_balancer.arn}"
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.markdown_server_target_group.arn}"
    }
}