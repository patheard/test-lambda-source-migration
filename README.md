# Test Lambda Terraform state migration
Test migrating a Lambda function's Terraform state when it changes from being managed directly by a `.zip` file to a `.zip` file stored in an S3 bucket.

This uses the Submission function from [cds-snc/forms-terraform](https://github.com/cds-snc/forms-terraform) as the test function code.