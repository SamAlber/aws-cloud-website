# CREATED AFTER EVERYTHING WAS SET UP! 
# BACKEND REQUIRES STATIC NAMES 
terraform {
  backend "s3" {
    bucket         = "terraform.tfstate-bra2hd"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-locks" # Optional, for state locking
    encrypt        = true
  }
}

# ------------------------- Bucket Creation ------------------------- #


resource "aws_s3_bucket" "tfstate" {
  bucket = "terraform.tfstate-${local.bucket_gen}"
  acl    = "private"

  tags = {
    Name = "Terraform State Bucket"
  }
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

/*
To secure the S3 bucket used for Terraform state (.tfstate), you should attach a bucket policy that grants access only to the specific IAM roles or users who need it. 
This policy ensures the bucket remains private and inaccessible to unauthorized users while still allowing Terraform operations to function.
*/
# Resource Based Policy attached directly to the resource - Directly grant access to specific resources (e.g., make a bucket public).
resource "aws_s3_bucket_policy" "tfstate_policy" {
  bucket = aws_s3_bucket.tfstate.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = [
            #"arn:aws:iam::123456789012:role/TerraformRole", # not using it. 
            "arn:aws:iam::761018880324:user/iamadmin" # giving only myself access , can be given to a user or a role.  
            # You are correctly using a specific IAM user (arn:aws:iam::761018880324:user/iamadmin) to restrict access. This is valid and ensures only the specified user has access.
          ]
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.tfstate.arn}", # should be arn, not id 
          "${aws_s3_bucket.tfstate.arn}/*"
        ]
        /* WHAT BEFORE (WRONG):
        The issue in your aws_s3_bucket_policy resource is in the Resource field. Specifically, you are referencing aws_s3_bucket.tfstate.arn 
        as a string inside the jsonencode function, but this doesn't dynamically resolve the ARN as expected. Instead, Terraform interprets it literally as the string "arn:aws:s3:::aws_s3_bucket.tfstate.arn".
        To dynamically reference the ARN, you must directly use aws_s3_bucket.tfstate.arn without wrapping it in quotes as a static string.
        Resource = [
          "arn:aws:s3:::aws_s3_bucket.tfstate.arn", # should be arn, not id 
          "arn:aws:s3:::aws_s3_bucket.tfstate.arn/*"
        ]
        */
      }
    ]
  })
}

# ------------------------- DynamoDB table ------------------------- #

resource "aws_dynamodb_table" "tfstate_locks" {
  name         = "tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "Dev"
  }
}

/*3. How DynamoDB Uses the Hash Key
The hash key determines:

Partition Placement:
DynamoDB uses the hash key value to calculate a hash.
The hash determines which partition the item is stored in.
Efficient Retrieval:
Query operations on the table use the hash key to find the relevant partition and retrieve the item efficiently.
*/

# Identity-Based Policy - Grant permissions to identities to access various AWS services/resources.
resource "aws_iam_policy" "tfstate_dynamodb_policy" {
  name        = "tfstate-dynamodb-policy"
  description = "Allow access to DynamoDB state locking"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DeleteItem"],
        Resource = "arn:aws:dynamodb:us-east-1:761018880324:table/tfstate-locks" # !!!!!!!!! Specifies on what resource and iam admin the policy is applied to, coud've used aws_dynamodb_table.tfstate_locks.arn but full is better.
        /*
        If the iamadmin user is configured to assume the role, they will be able to:

        Assume the role using the sts:AssumeRole API.
        Temporarily receive credentials from AWS Security Token Service (STS).
        Perform actions defined in the policies attached to the role during the duration of the session.

        IAM Policies (Attached to the Role):

        Define what the role can do.
        For example, if the role has permissions to interact with DynamoDB (dynamodb:PutItem, GetItem, DeleteItem), then the iamadmin user will temporarily inherit these permissions while assuming the role.      
        */
      }
    ]
  })
}

# IAM Role with Policies - Provide temporary credentials for AWS services to interact with resources. 
# iamadmin user will assume the role and receive the sts and will be able to do all what defined in the policies. 
resource "aws_iam_role" "tfstate_table_role" {
  name = "terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::761018880324:user/iamadmin" # Replace with the entity ARN
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_policy" {
  role       = aws_iam_role.tfstate_table_role.name
  policy_arn = aws_iam_policy.tfstate_dynamodb_policy.arn
}

#--------------------------------------# 

output "tfstate_bucket_name" {
  value = aws_s3_bucket.tfstate.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tfstate_locks.name
}

/*

OR AS A ROLE AS AN EXAMPLE

resource "aws_iam_policy" "tfstate_dynamodb_policy" {
  name        = "tfstate-dynamodb-policy"
  description = "Allow access to DynamoDB state locking"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DeleteItem"]
        Resource  = "aws_dynamodb_table.tfstate_locks.arn"                              !!!The specific resource we're talking about 
      }
    ]
  })
}

For whom all the permissions are. 
resource "aws_iam_role" "terraform_role" {
  name = "terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" } # or other service/user
        Action    = "sts:AssumeRole"                                                !!!!!! This what grants the service that assumes the role a token
      }
    ]
  })
}

!!!!!!!! Attaching policy to the role that will be attached to the services (the services specifies the role within itself)
resource "aws_iam_role_policy_attachment" "attach_dynamodb_policy" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.tfstate_dynamodb_policy.arn
}

The aws_iam_role defines who can assume the role.
The aws_iam_policy defines what the role can do (e.g., PutItem, GetItem in DynamoDB).
The aws_iam_role_policy_attachment links the role to the policy, granting permissions to the entity assuming the role.

!The aws_iam_policy itself does not attach directly to a role unless explicitly linked using an attachment mechanism like aws_iam_role_policy_attachment.

The aws_iam_policy itself does not attach directly to a role unless explicitly linked using an attachment mechanism like aws_iam_role_policy_attachment.

Summary
The aws_iam_policy defines what actions and resources are allowed, but by itself, it does nothing.
The aws_iam_role_policy_attachment is essential to attach the policy to a role.
|
v
the service like lambda assumes the role with all of it's permissions.


*/
