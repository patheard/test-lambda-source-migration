# Test Lambda .zip to S3 object migration
Test migrating a Lambda function from being managed directly by a `.zip` file to a `.zip` file stored in an S3 bucket.

This uses the Submission function from [cds-snc/forms-terraform](https://github.com/cds-snc/forms-terraform) as the test function code.

## Tests
### 1. v1.0 to v2.0 (no state migration)
```bash
git checkout v1.0 # Lambda function managed using .zip
terraform init
terraform apply

git checkout v2.0 # Lambda function managed using .zip in S3 bucket
terraform apply
```

Result was a 12s update-in-place of the Submission lambda:

```terraform
Terraform will perform the following actions:

  # aws_lambda_function.submission will be updated in-place
  ~ resource "aws_lambda_function" "submission" {
      - filename                       = "/tmp/submission_main.zip" -> null
        id                             = "Submission"
      ~ last_modified                  = "2024-01-20T16:03:05.518+0000" -> (known after apply)
      ~ layers                         = [
          - "arn:aws:lambda:ca-central-1:571510889204:layer:submission_node_packages:1",
        ]
      + s3_bucket                      = (known after apply)
      + s3_key                         = "submission_code"
      + s3_object_version              = (known after apply)
      ~ source_code_hash               = "q/+pOrWiAE/H9/h9VmzMyUx9E0075hNNF6JI6diB34w=" -> "JsLrfuaaGTY5XHJLVGFMYJPwzqBqZqg+dmulhvL8YRQ="
        tags                           = {}
        # (18 unchanged attributes hidden)

        # (3 unchanged blocks hidden)
    }

  # aws_lambda_layer_version.submission_lib will be destroyed
  # (because aws_lambda_layer_version.submission_lib is not in configuration)
  - resource "aws_lambda_layer_version" "submission_lib" {
      - arn                      = "arn:aws:lambda:ca-central-1:571510889204:layer:submission_node_packages:1" -> null
      - compatible_architectures = [] -> null
      - compatible_runtimes      = [
          - "nodejs18.x",
        ] -> null
      - created_date             = "2024-01-20T16:03:04.472+0000" -> null
      - filename                 = "/tmp/submission_lib.zip" -> null
      - id                       = "arn:aws:lambda:ca-central-1:571510889204:layer:submission_node_packages:1" -> null
      - layer_arn                = "arn:aws:lambda:ca-central-1:571510889204:layer:submission_node_packages" -> null
      - layer_name               = "submission_node_packages" -> null
      - skip_destroy             = false -> null
      - source_code_hash         = "kDNPwPBKCiqMVMLkSJCLDc6yM33IcNzFVqX8FRAJoFY=" -> null
      - source_code_size         = 2743777 -> null
      - version                  = "1" -> null
    }

  # aws_s3_bucket.lambda_code will be created
  + resource "aws_s3_bucket" "lambda_code" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "test-forms-terraform-lambda-code"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags_all                    = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)
    }

  # aws_s3_bucket_ownership_controls.lambda_code will be created
  + resource "aws_s3_bucket_ownership_controls" "lambda_code" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + object_ownership = "BucketOwnerEnforced"
        }
    }

  # aws_s3_bucket_public_access_block.lambda_code will be created
  + resource "aws_s3_bucket_public_access_block" "lambda_code" {
      + block_public_acls       = true
      + block_public_policy     = true
      + bucket                  = (known after apply)
      + id                      = (known after apply)
      + ignore_public_acls      = true
      + restrict_public_buckets = true
    }

  # aws_s3_bucket_server_side_encryption_configuration.lambda_code will be created
  + resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_code" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + apply_server_side_encryption_by_default {
              + sse_algorithm = "AES256"
            }
        }
    }

  # aws_s3_bucket_versioning.lambda_code will be created
  + resource "aws_s3_bucket_versioning" "lambda_code" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

  # aws_s3_object.submission_code will be created
  + resource "aws_s3_object" "submission_code" {
      + acl                    = (known after apply)
      + bucket                 = (known after apply)
      + bucket_key_enabled     = (known after apply)
      + checksum_crc32         = (known after apply)
      + checksum_crc32c        = (known after apply)
      + checksum_sha1          = (known after apply)
      + checksum_sha256        = (known after apply)
      + content_type           = (known after apply)
      + etag                   = (known after apply)
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "submission_code"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "/tmp/submission_code.zip"
      + source_hash            = "JsLrfuaaGTY5XHJLVGFMYJPwzqBqZqg+dmulhvL8YRQ="
      + storage_class          = (known after apply)
      + tags_all               = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 6 to add, 1 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_lambda_layer_version.submission_lib: Destroying... [id=arn:aws:lambda:ca-central-1:571510889204:layer:submission_node_packages:1]
aws_s3_bucket.lambda_code: Creating...
aws_lambda_layer_version.submission_lib: Destruction complete after 0s
aws_s3_bucket.lambda_code: Creation complete after 1s [id=test-forms-terraform-lambda-code]
aws_s3_bucket_public_access_block.lambda_code: Creating...
aws_s3_bucket_ownership_controls.lambda_code: Creating...
aws_s3_bucket_server_side_encryption_configuration.lambda_code: Creating...
aws_s3_bucket_versioning.lambda_code: Creating...
aws_s3_object.submission_code: Creating...
aws_s3_bucket_public_access_block.lambda_code: Creation complete after 0s [id=test-forms-terraform-lambda-code]
aws_s3_bucket_server_side_encryption_configuration.lambda_code: Creation complete after 1s [id=test-forms-terraform-lambda-code]
aws_s3_bucket_ownership_controls.lambda_code: Creation complete after 1s [id=test-forms-terraform-lambda-code]
aws_s3_object.submission_code: Creation complete after 1s [id=submission_code]
aws_lambda_function.submission: Modifying... [id=Submission]
aws_s3_bucket_versioning.lambda_code: Creation complete after 2s [id=test-forms-terraform-lambda-code]
aws_lambda_function.submission: Still modifying... [id=Submission, 10s elapsed]
aws_lambda_function.submission: Modifications complete after 12s [id=Submission]

Apply complete! Resources: 6 added, 1 changed, 1 destroyed.
```

### 2. v1.0 to v3.0 (state migration)
```bash
git checkout v1.0 # Lambda function managed using .zip
terraform init
terraform apply

git checkout v3.0 # Lambda function managed using .zip in S3 bucket, new state
cd ./terraform
terraform init
terraform apply -target=aws_s3_bucket.lambda_code # bootstrap creation of new state
./migrate.sh # migrate resources from old state to new state
terraform apply
```

Result was an 11s update-in-place of the Submission lambda:

```terraform
Terraform will perform the following actions:

  # aws_lambda_function.submission will be updated in-place
  ~ resource "aws_lambda_function" "submission" {
      - filename                       = "/tmp/submission_main.zip" -> null
        id                             = "Submission"
      ~ last_modified                  = "2024-01-20T17:42:01.871+0000" -> (known after apply)
      ~ layers                         = [
          - "arn:aws:lambda:ca-central-1:571510889204:layer:submission_node_packages:2",
        ]
      + s3_bucket                      = "test-forms-terraform-lambda-code"
      + s3_key                         = "submission_code"
      + s3_object_version              = (known after apply)
      ~ source_code_hash               = "q/+pOrWiAE/H9/h9VmzMyUx9E0075hNNF6JI6diB34w=" -> "JsLrfuaaGTY5XHJLVGFMYJPwzqBqZqg+dmulhvL8YRQ="
        tags                           = {}
        # (18 unchanged attributes hidden)

        # (3 unchanged blocks hidden)
    }

  # aws_s3_bucket_ownership_controls.lambda_code will be created
  + resource "aws_s3_bucket_ownership_controls" "lambda_code" {
      + bucket = "test-forms-terraform-lambda-code"
      + id     = (known after apply)

      + rule {
          + object_ownership = "BucketOwnerEnforced"
        }
    }

  # aws_s3_bucket_public_access_block.lambda_code will be created
  + resource "aws_s3_bucket_public_access_block" "lambda_code" {
      + block_public_acls       = true
      + block_public_policy     = true
      + bucket                  = "test-forms-terraform-lambda-code"
      + id                      = (known after apply)
      + ignore_public_acls      = true
      + restrict_public_buckets = true
    }

  # aws_s3_bucket_server_side_encryption_configuration.lambda_code will be created
  + resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_code" {
      + bucket = "test-forms-terraform-lambda-code"
      + id     = (known after apply)

      + rule {
          + apply_server_side_encryption_by_default {
              + sse_algorithm = "AES256"
            }
        }
    }

  # aws_s3_bucket_versioning.lambda_code will be created
  + resource "aws_s3_bucket_versioning" "lambda_code" {
      + bucket = "test-forms-terraform-lambda-code"
      + id     = (known after apply)

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

  # aws_s3_object.submission_code will be created
  + resource "aws_s3_object" "submission_code" {
      + acl                    = (known after apply)
      + bucket                 = "test-forms-terraform-lambda-code"
      + bucket_key_enabled     = (known after apply)
      + checksum_crc32         = (known after apply)
      + checksum_crc32c        = (known after apply)
      + checksum_sha1          = (known after apply)
      + checksum_sha256        = (known after apply)
      + content_type           = (known after apply)
      + etag                   = (known after apply)
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "submission_code"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "/tmp/submission_code.zip"
      + source_hash            = "JsLrfuaaGTY5XHJLVGFMYJPwzqBqZqg+dmulhvL8YRQ="
      + storage_class          = (known after apply)
      + tags_all               = (known after apply)
      + version_id             = (known after apply)
    }

Plan: 5 to add, 1 to change, 0 to destroy.

...

aws_lambda_function.submission: Modifications complete after 11s [id=Submission]
```