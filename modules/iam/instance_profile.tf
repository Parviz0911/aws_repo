resource "aws_iam_instance_profile" "codebuild_profile" {
  name = "codebuild"
  role = aws_iam_role.deploy_role.name
}

#######################################################

resource "aws_iam_role" "deploy_role" {
  name = "ec2_deploy_role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "deploy_policy" {
  name        = "s3-deploy-${var.environment}"
  path        = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:ListBucket",
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_policy_attachment" "ec2_role_attach" {
  name       = "ec2-attachment-${var.environment}"
  roles      = [aws_iam_role.deploy_role.name]
  policy_arn = aws_iam_policy.deploy_policy.arn
}