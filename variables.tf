variable "aws_services" {
  type = list
  default = [
    "apigateway",
  ]

  description = "List of AWS services supported New Relic: elasticloadbalancing, apigateway, budgets, cloudfront, dynamodb, ec2, ecs, elasticfilesystem, es, elasticbeanstalk, elasticmapreduce, health, iam, iot, firehose, kinesis, rds, route53, s3, ses, sns, sqs, lambda, cloudwatch, and/or support."
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "priority" {
  type    = string
  default = "P2"
}

variable "create_route53_healthcheck" {
  type    = bool
  default = true
}
