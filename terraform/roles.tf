// Some ecs task execution role stuff I'm not sure about but
// apparently its required to deploy tasks on ecs.
// Andrew says you gotta do this so who am I to question Andrew?
// https://medium.com/avmconsulting-blog/how-to-deploy-a-dockerised-node-js-application-on-aws-ecs-with-terraform-3e6bceb48785
resource "aws_iam_role" "ecsTaskExecutionRole" {
    name = "ecsTaskExecutionRole1"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}