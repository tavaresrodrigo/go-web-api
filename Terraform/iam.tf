resource "aws_iam_role" "gowebapi-task-execution-role" {
    name = "${var.name}-task-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    })
    tags = merge(
        local.tags,
        {
            Name = "${var.name}-task-role"
        }
    )
}

resource "aws_iam_role_policy_attachment" "gowebapi-task-role-policy" {
    role = "${aws_iam_role.gowebapi-task-execution-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
