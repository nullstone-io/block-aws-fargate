resource "aws_iam_role" "execution" {
  name               = "execution-${local.resource_name}"
  assume_role_policy = data.aws_iam_policy_document.execution.json
  tags               = data.ns_workspace.this.tags
}

data "aws_iam_policy_document" "execution" {
  statement {
    sid     = "AllowECSAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "execution-managed" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

// App Mesh Envoy policy for accessing Virtual Node configuration
resource "aws_iam_role_policy_attachment" "execution_envoy" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
}

// Create policy to pass the execution role to ECS
resource "aws_iam_policy" "execution-pass-role" {
  name_prefix = "execution-${local.resource_name}"
  policy      = data.aws_iam_policy_document.deployer-execution.json
}

data "aws_iam_policy_document" "deployer-execution" {
  statement {
    sid       = "AllowPassRoleToECS"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.execution.arn]
  }
}
