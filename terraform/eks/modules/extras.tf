resource "aws_s3_bucket" "bucket" {
  bucket = "my-web-assets-bucket"
}

resource "aws_s3_bucket_policy" "allow_app" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.allow_app.json
}

data "aws_iam_policy_document" "allow_app" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${var.aws_account_id}"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

resource "aws_sqs_queue" "queue" {
  name                      = "lms-import-data"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue_policy" "allow_app" {
  queue_url = aws_sqs_queue.queue.id
  policy    = data.aws_iam_policy_document.sqs_allow_app.json
}

data "aws_iam_policy_document" "sqs_allow_app" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${var.aws_account_id}"]
    }

    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]

    resources = [
      "${aws_sqs_queue.queue.arn}/*"
    ]
  }
}

variable "aws_account_id" {
  type = string
}
