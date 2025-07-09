resource "aws_s3_bucket" "example" {
  bucket = var.aritifact_bucket_name
  acl    = "private"
      provisioner "local-exec" {
    when    = destroy
    #command = "echo ${self.id} > testfile.txt"
    command = "aws s3 rm s3://rady-bucket-pipeline-artifacts --recursive"
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  #role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "ec2:*",
        "ssm:*",
        "*"
      ],
      "Resource": [
        "${aws_s3_bucket.example.arn}",
        "${aws_s3_bucket.example.arn}/*",
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codebuild:*",
        "ssm:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

variable "aritifact_bucket_name" {
  description = "the name you need to give to an artifact bucket"
  default = "rady-bucket-pipeline-artifacts"
}