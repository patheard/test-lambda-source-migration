#!/bin/bash

resources=(
    "aws_lambda_function.submission"
    "aws_cloudwatch_log_group.submission"
    "aws_iam_role.lambda"
    "aws_iam_policy.lambda_logging"
    "aws_iam_policy_attachment.lambda_logging"
)

for resource in ${resources[@]}; do
  echo "Migrating state for $resource"
  terraform state mv \
    -state=../terraform.tfstate \
    -state-out=./terraform.tfstate \
    "$resource" "$resource"
done
