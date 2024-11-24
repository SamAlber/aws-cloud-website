# AWS Resume Website

![Architecture](https://github.com/SamAlber/aws-cloud-website/blob/main/website/assets/imgs/architecture.png)

## **Project Overview**

Welcome to my AWS Resume Website project! This is a hands-on endeavor where I've integrated modern cloud technologies, DevOps practices, and web security best practices to create a dynamic resume website. It not only showcases my resume but also includes interactive features like a cryptocurrency price tracker and a visitor counter.

Check it out live at: [www.samuelalber.com](http://www.samuelalber.com)

### **Key Features**

1. **Static Website Hosting**:
   - Hosted on **Amazon S3** with **CloudFront** as a Content Delivery Network (CDN) to deliver content globally with low latency.
   - **Cloudflare** is used for DNS management and SSL/TLS configuration to enhance security and performance.
   - **Domain Purchased from Cloudflare**: The domain `samuelalber.com` was purchased through Cloudflare and configured to work seamlessly with AWS services.

2. **Dynamic Backend Functionalities**:
   - **Cryptocurrency Price Tracker**: Displays live cryptocurrency prices and logos fetched from an external API.
   - **CV Request Feature**: Allows users to request a copy of my CV via email using **AWS SES** and provides a secure, time-limited download link.
   - **Visitor Counter**: Tracks and displays the number of visitors using **DynamoDB** and **AWS Lambda**, showcasing real-time data updates.

3. **Infrastructure as Code**:
   - All resources are provisioned and managed using **Terraform**, ensuring consistency, version control, and scalability.

4. **Continuous Integration and Deployment**:
   - Implemented **GitHub Actions** to automate the deployment of the frontend website to S3 whenever changes are pushed to the Git repository.

5. **Security**:
   - **CloudFront Origin Access Control (OAC)** restricts direct access to the S3 bucket, ensuring content is served only through CloudFront.
   - **AWS Certificate Manager (ACM)** is used for managing SSL/TLS certificates, providing secure HTTPS communication.
   - Sensitive data such as API keys and configuration parameters are securely stored in **AWS Systems Manager Parameter Store**.

6. **Frontend**:
   - **Template-Based Design**: The frontend was built using a pre-designed template, which I customized to suit my needs.
   - Utilized **HTML**, **CSS**, and **JavaScript** to provide an interactive and responsive user experience.

---

## **Services and Tools Used**

### **AWS Services**

- **Amazon S3**: For static website hosting.
- **Amazon CloudFront**: Serves as the CDN to deliver content efficiently.
- **AWS Lambda**: Hosts serverless backend functions for API and business logic.
- **Amazon API Gateway**: Provides RESTful APIs for frontend-backend communication.
- **Amazon DynamoDB**: NoSQL database for storing visitor counts.
- **Amazon SES (Simple Email Service)**: Sends emails for CV requests.
- **AWS ACM (Certificate Manager)**: Manages SSL/TLS certificates for secure communication.
- **AWS SSM (Systems Manager) Parameter Store**: Secure storage for configuration data and secrets.

### **Other Services and Tools**

- **Cloudflare**:
  - **Domain Registration**: Purchased the domain `samuelalber.com` through Cloudflare.
  - **DNS Management**: Manages DNS settings, providing quick propagation and easy management.
  - **SSL/TLS Configuration**: Worked in conjunction with AWS ACM to ensure end-to-end encryption.

- **Terraform**: Infrastructure as Code tool used for provisioning and managing AWS resources.

- **GitHub Actions**: Used for Continuous Integration and Deployment (CI/CD) to automate the frontend deployment process.

---

## **Development Flow**

### **1. Frontend Development**

- **Template Customization**:
  - Started with a professional frontend template to ensure a polished and responsive design.
  - Customized the template extensively to reflect my personal branding and content.
  - Adjusted layouts, color schemes, and components to align with the project's requirements.

- **Dynamic Content with JavaScript**:
  - Implemented **JavaScript** to handle API calls and DOM manipulation.
  - Used **Fetch API** to retrieve data asynchronously from backend services.

### **2. Backend Implementation**

- **Programming Language**:
  - All backend code, including Lambda functions, was written in **Python**.

#### **Handling S3 Bucket Configurations**

- **Public Access Settings**:
  - Implemented strict S3 bucket policies to prevent public access:
    - Used `aws_s3_bucket_public_access_block` to block all public ACLs and policies, ensuring that even if an ACL is misconfigured, public access is still blocked.
    - Configured `aws_s3_bucket_ownership_controls` with `object_ownership = "BucketOwnerPreferred"` to ensure the bucket owner retains ownership of all objects, even if uploaded by other AWS accounts.
  - Set the bucket ACL to `private` using `aws_s3_bucket_acl` to enforce default object permissions.

- **CORS Configuration**:
  - For the website bucket, set up CORS rules to allow GET requests from any origin:
    - This is crucial for allowing CloudFront to fetch content from S3 and serve it to different domains.
    - Configured using `aws_s3_bucket_cors_configuration`.

#### **IAM Roles and Policies**

- **Resource-Based Policies vs. Identity-Based Policies**:
  - Used resource-based policies (e.g., S3 bucket policies) to grant access to specific resources.
  - Attached identity-based policies to IAM roles to grant permissions to AWS services like Lambda.
  - Understood the importance of `sts:AssumeRole` in IAM roles, which allows AWS services to assume the role and gain necessary permissions.

- **Principal Types in Policies**:
  - Differentiated between service principals (e.g., `"Service": "lambda.amazonaws.com"`) and AWS principals (e.g., `"AWS": "arn:aws:iam::account-id:user/username"`).

#### **Lambda Functions and Layers**

- **Lambda Layers**:
  - Created a Lambda Layer to include external Python libraries (e.g., `rsa` module) that are not available in the standard Lambda runtime.
  - This ensures that dependencies are managed efficiently and consistently across functions.

- **Using Boto3**:
  - Utilized the `boto3` library in Python code to interact with AWS services like DynamoDB, SES, and SSM Parameter Store.
  - Enabled dynamic data retrieval and manipulation within Lambda functions.

#### **CloudFront and S3 Integration**

- **Origin Access Control (OAC)**:
  - Configured CloudFront with OAC to securely access private S3 buckets:
    - Implemented using `aws_cloudfront_origin_access_control`.
    - Ensured that S3 buckets are not publicly accessible and can only be accessed through CloudFront.
  - Updated S3 bucket policies to allow access from CloudFront using the OAC.

- **Signed URLs and OAC Compatibility**:
  - Ensured that signed URLs work in tandem with OAC by properly configuring the CloudFront distribution and S3 bucket policies.
  - Established a secure chain of trust where users access content via CloudFront using signed URLs, and CloudFront accesses the S3 bucket using OAC.

#### **API Gateway and Lambda Integration**

- **Handling CORS and Preflight Requests**:
  - Configured API Gateway methods to handle OPTIONS requests for CORS preflight checks:
    - Added OPTIONS methods using `aws_api_gateway_method`.
    - Integrated these methods with Lambda functions using `aws_api_gateway_integration`.
  - For AWS_PROXY integrations, updated Lambda functions to handle OPTIONS requests and include necessary CORS headers in the responses.

- **Dependence Management in Terraform**:
  - Used `depends_on` in Terraform to ensure resources are created in the correct order.
  - This prevents deployment failures due to resource dependencies not being met.

#### **Terraform State Management**

- **Storing State Files Securely**:
  - Configured Terraform to use an S3 bucket as a remote backend for state files:
    - Enhanced collaboration by ensuring everyone uses the same state.
    - Improved security by storing state files remotely.
  - Enabled state locking with DynamoDB to prevent concurrent modifications:
    - Prevents state file corruption due to simultaneous operations.

- **Ignoring Unnecessary Files**:
  - Updated `.gitignore` to exclude directories like `.terraform/` and untracked them from the repository:
    - Ensures that local environment files are not pushed to version control.

### **3. Infrastructure Automation**

- **Terraform Configuration**:
  - Wrote Terraform scripts to define AWS resources like S3 buckets, Lambda functions, API Gateway, DynamoDB tables, and IAM roles.
  - Included detailed comments in the Terraform code to explain configurations and important considerations.
  - Used modules and organized code for clarity and reusability.

- **Version Control**:
  - Stored Terraform code in a Git repository for versioning and collaboration.
  - Ensured sensitive information is managed securely.

### **4. Continuous Integration and Deployment (CI/CD)**

- **GitHub Actions**:
  - Set up workflows to automatically deploy the frontend website to the S3 bucket whenever changes are pushed to the Git repository.
  - Configured actions to build, test, and deploy code, ensuring a streamlined development process.
  - Managed AWS credentials securely using GitHub Secrets.

- **Addressing Public Access Settings**:
  - Resolved issues with S3 bucket public access settings by adjusting bucket policies and removing unnecessary ACL configurations.
  - Ensured that the `--acl public-read` flag was used appropriately in deployment scripts.

---

## **Domain Purchase and SSL/TLS Configuration**

- **Domain Registration with Cloudflare**:
  - Purchased `samuelalber.com` from Cloudflare, taking advantage of their competitive pricing and reliable services.

- **DNS Management**:
  - Configured DNS records in Cloudflare to point to the AWS CloudFront distribution.
  - Set up CNAME records for `www.samuelalber.com` and `samuelalber.com` to ensure both resolve correctly.

- **SSL/TLS Integration with AWS ACM**:
  - Requested SSL/TLS certificates from **AWS Certificate Manager** for the domain and subdomains.
  - Validated domain ownership through DNS validation by adding CNAME records provided by ACM to Cloudflare's DNS settings.
  - Configured CloudFront to use the SSL/TLS certificates from ACM, enabling HTTPS access to the website.

- **End-to-End Encryption**:
  - Ensured that data is encrypted in transit from the user's browser to CloudFront and from CloudFront to S3.
  - Set CloudFront to use HTTPS when communicating with origin servers (S3 bucket).

---

## **RSA Encryption and CloudFront Signed URLs**

### **How RSA Works in This Project**

- **RSA Encryption**:
  - RSA is an asymmetric cryptographic algorithm that uses a pair of keys: a **public key** and a **private key**.
  - The **private key** is used to sign data, and the **public key** is used to verify the signature.

- **CloudFrontSigner and RSA in Python**:
  - In the Lambda function for the CV Request Feature, I used **CloudFrontSigner** from the `aws-cloudfront-sign` module.
  - The `CloudFrontSigner` requires an RSA private key to generate signed URLs.
  - The **rsa** Python library is used to load and manage the RSA private key within the code.

- **Generating Signed URLs**:
  - The Lambda function uses the RSA private key to sign a policy that includes the URL, expiration time, and access restrictions.
  - The signed URL allows temporary access to the CV stored in S3 via CloudFront, ensuring that only users with the signed URL can download the file.

### **Security Benefits**

- **Access Control**:
  - By using signed URLs, unauthorized users cannot access the content even if they know the URL, because they lack the valid signature.
  - The RSA-signed URL ensures that only users who have requested the CV and received the email can access the download link.

- **Time-Limited Access**:
  - The signed URLs have an expiration time, after which they become invalid.
  - This limits the window during which the CV can be downloaded, enhancing security.

- **Key Management**:
  - The RSA private key is securely stored in **AWS SSM Parameter Store**.
  - The public key is associated with a CloudFront key group, which CloudFront uses to verify the signature.
  - This separation ensures that even if the public key is exposed, the private key remains secure.

---

## **User Flow**

### **1. Accessing the Website**

When you type `www.samuelalber.com` into your browser, here's what happens behind the scenes:

1. **Browser Cache Check**:
   - The browser checks its local DNS cache to see if it already knows the IP address.

2. **Recursive DNS Resolver Query**:
   - If not cached, the browser queries a recursive DNS resolver (often provided by your ISP or a public DNS service like Google DNS).

3. **Root DNS Servers**:
   - The resolver starts at the root DNS servers, which handle queries for top-level domains (TLDs).

4. **Top-Level Domain (TLD) Servers**:
   - The resolver queries the TLD name servers responsible for `.com` domains to find the authoritative name servers for `samuelalber.com`.

5. **Cloudflare Authoritative Name Servers**:
   - The resolver contacts Cloudflare's authoritative name servers for `samuelalber.com`.

6. **DNS Record Retrieval**:
   - Cloudflare provides the DNS records, including the CNAME pointing to the AWS CloudFront distribution.

7. **Connecting to CloudFront**:
   - The browser resolves the CNAME to the CloudFront distribution's IP address.
   - **SSL/TLS Handshake**: A secure connection is established using SSL/TLS certificates managed by AWS ACM and recognized by Cloudflare.

8. **Content Delivery**:
   - CloudFront serves the requested content:
     - **Cached Content**: Delivered immediately from the nearest edge location.
     - **Non-Cached Content**: Fetched from the origin S3 bucket, cached, and then delivered.

9. **Rendering the Website**:
   - The browser downloads the HTML, CSS, and JavaScript files.
   - The website is rendered, and dynamic content is loaded.

### **2. Using Dynamic Features**

#### **Cryptocurrency Price Tracker**:

1. **Frontend Request**:
   - JavaScript initiates a GET request to the API Gateway endpoint for cryptocurrency data.

2. **API Gateway Processing**:
   - Routes the request to the appropriate Lambda function written in Python.

3. **Lambda Execution**:
   - Fetches live data from an external cryptocurrency API.
   - Formats the data into a JSON response.

4. **Data Delivery**:
   - The response is sent back through API Gateway to the frontend.

5. **Dynamic Display**:
   - JavaScript updates the DOM to display current prices and logos.

#### **CV Request**:

1. **User Interaction**:
   - You enter your email address and click the "Receive My CV" button.

2. **API Call**:
   - The frontend sends a POST request containing your email to the API Gateway.

3. **Lambda Function Workflow**:
   - **Email Validation**: Ensures the email is in the correct format.
   - **Signed URL Generation**:
     - Uses the **rsa** library to load the RSA private key.
     - The **CloudFrontSigner** creates a signed URL using the private key.
     - The URL includes a policy that specifies expiration time and access permissions.
   - **Email Sending**: Sends an email via SES with the signed URL.

4. **Email Receipt**:
   - You receive an email with a secure link to download the CV.

5. **Secure Download**:
   - The link allows you to download the CV directly from CloudFront, with access controlled via the signed URL.
   - CloudFront uses the associated public key to verify the signature and enforce the policy.

#### **Visitor Counter**:

1. **Counter Request**:
   - Upon loading the website, JavaScript sends a GET request to the visitor counter API.

2. **Lambda Function Execution**:
   - **Read and Increment**: Retrieves the current count from DynamoDB, increments it, and writes it back.
   - **Concurrency Handling**: Uses DynamoDB's conditional updates to handle simultaneous requests.

3. **Response to Frontend**:
   - Sends the updated count back to the frontend.

4. **Display Update**:
   - The visitor count is updated on the website in real-time.

---

## **Challenges and Solutions**

### **1. Handling CORS (Cross-Origin Resource Sharing) Issues**

**Challenge**:

- Encountered CORS errors when the frontend JavaScript tried to make API calls to the backend services hosted on different domains.
- Specifically, pressing the "Receive My CV" button resulted in CORS errors due to missing or incorrect handling of preflight OPTIONS requests.

**Understanding Preflight CORS and the OPTIONS Method**:

- **Preflight Requests**:
  - Browsers send a preflight OPTIONS request before making certain cross-origin requests, especially when using methods like POST with custom headers.
- **OPTIONS Method**:
  - The server must respond to the OPTIONS request with the appropriate CORS headers to indicate that the cross-origin request is allowed.
- **Why OPTIONS Is Needed**:
  - Without handling the OPTIONS request, the browser will block the actual request, resulting in a CORS error.

**Solution**:

- **API Gateway Configuration**:
  - Added the OPTIONS method to the API Gateway resources.
  - Configured the method and integration for OPTIONS using `aws_api_gateway_method` and `aws_api_gateway_integration` in Terraform.
  - Ensured that both the method and integration for OPTIONS were properly set up.
- **Lambda Function Adjustments**:
  - For AWS_PROXY integrations, modified Lambda functions to handle OPTIONS requests and include CORS headers in the response:
    ```python
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        },
        'body': ''
    }
    ```
- **Key Takeaways**:
  - **Mandatory Headers**:
    - Including CORS headers in the Lambda function responses is essential for the browser to accept the responses.
  - **Testing**:
    - Tested the API behavior using tools like `curl` and the API Gateway console to ensure that both OPTIONS and POST methods worked correctly.
  - **Depends On in Terraform**:
    - Used `depends_on` in Terraform to ensure that resources were created in the correct order, particularly for API Gateway deployments.

### **2. Managing Resource Dependencies in Terraform**

**Challenge**:

- Deployment failures occurred because Terraform tried to create resources before their dependencies were ready.
- Specifically, the API Gateway deployment failed because methods and integrations were not fully set up.

**Solution**:

- **Using `depends_on`**:
  - Employed the `depends_on` attribute in Terraform resource blocks to define explicit dependencies.
  - For example, in the `aws_api_gateway_deployment` resource, added dependencies on methods and integrations:
    ```hcl
    resource "aws_api_gateway_deployment" "api_deployment" {
      depends_on = [
        aws_api_gateway_integration.lambda_integration,
        aws_api_gateway_integration.send_cv_post_integration,
        aws_api_gateway_integration.crypto_api_integration,
        aws_api_gateway_integration.send_cv_options_integration
      ]
      rest_api_id = aws_api_gateway_rest_api.viewer_count_api.id
    }
    ```
- **Organizing Terraform Code**:
  - Split Terraform configurations into modules and organized code for clarity.
  - Used `terraform.tfvars` for variable management.

### **3. Understanding IAM Policies and Roles**

**Challenge**:

- Confusion between resource-based policies and identity-based policies.
- Needed to understand when to use IAM roles and how `sts:AssumeRole` works.

**Solution**:

- **Resource-Based Policies**:
  - Standalone policies attached directly to resources (e.g., S3 bucket policies).
  - Used for granting cross-account access or public access to resources.
- **Identity-Based Policies**:
  - Policies attached to IAM identities (users, groups, roles).
  - Used for granting permissions to identities to access AWS resources.
- **IAM Roles and `sts:AssumeRole`**:
  - Created IAM roles for AWS services (e.g., Lambda) to assume.
  - The `sts:AssumeRole` action in the trust policy allows the service to assume the role.
  - Example trust policy:
    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
    ```
- **Understanding `Action = "sts:AssumeRole"`**:
  - Allows trusted entities to assume the role and gain the permissions attached to it.

### **4. Securing Terraform State Files**

**Challenge**:

- Needed to store Terraform state files (`terraform.tfstate`) securely and enable collaboration.

**Solution**:

- **Remote Backend Configuration**:
  - Configured Terraform to use an S3 bucket as a remote backend for state files.
  - Enabled state locking using a DynamoDB table to prevent concurrent modifications.
- **S3 Bucket and DynamoDB Setup**:
  ```hcl
  terraform {
    backend "s3" {
      bucket         = "your-s3-bucket-name"
      key            = "path/to/terraform.tfstate"
      region         = "your-region"
      dynamodb_table = "terraform-lock-table"
    }
  }
  ```
- **Ensuring Bucket Privacy**:
  - Set up the S3 bucket to be private, as Terraform state files can contain sensitive information.
  - Did not expose the bucket via CloudFront, as it's unnecessary for state files.
- **IAM Permissions**:
  - Provided necessary IAM permissions for users and CI/CD systems to access the S3 bucket and DynamoDB table.
  - Used IAM roles and policies to manage access securely.

### **5. Resolving CloudFront and S3 Access Issues**

**Challenge**:

- Encountered "Access Denied" errors when CloudFront attempted to access objects in the S3 bucket.
- Needed to understand the relationship between CloudFront Origin Access Control (OAC) and signed URLs.

**Solution**:

- **Using OAC with Signed URLs**:
  - Configured **CloudFront Origin Access Control (OAC)** to allow CloudFront to access the private S3 bucket securely.
  - Updated the S3 bucket policy to grant access to the OAC.
  - Confirmed that OAC and signed URLs can be used together, as they secure different parts of the access flow.
- **Mandatory `origin_access_control_id`**:
  - Ensured that `origin_access_control_id` was set in the CloudFront distribution to enable SigV4 signing.
  - Without it, CloudFront cannot make authenticated requests to the private S3 bucket.
- **S3 Bucket Policy**:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowCloudFrontAccess",
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudfront.amazonaws.com"
        },
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::your-bucket-name/*",
        "Condition": {
          "StringEquals": {
            "AWS:SourceArn": "arn:aws:cloudfront::your-account-id:distribution/your-distribution-id"
          }
        }
      }
    ]
  }
  ```
- **Chain of Trust with CloudFront and S3**:
  - Established a secure chain of trust where users access content via CloudFront using signed URLs, and CloudFront accesses the S3 bucket using OAC.

### **6. GitHub Actions and CI/CD Challenges**

**Challenge**:

- Needed to automate the deployment process and manage AWS credentials securely.
- Encountered issues with public access settings when uploading the website via GitHub Actions.

**Solution**:

- **Automating Deployment**:
  - Configured GitHub Actions workflows to deploy the frontend to S3 on code pushes.
  - Ensured that AWS credentials were securely managed using GitHub Secrets.
- **Public Access Settings**:
  - S3 buckets have default block public access settings that prevent public-read ACLs.
  - Adjusted the bucket policy and ACLs to allow public access where appropriate.
  - Removed the `--acl public-read` flag from the AWS CLI commands in the workflow, as it was unnecessary and caused errors.
- **Ignoring Unnecessary Files in Git**:
  - Added `.gitignore` entries to exclude directories like `.terraform/` from being tracked.
  - Used `git rm -r --cached .terraform` to untrack files already committed.

---

## **Future Goals**

- **Portfolio Expansion**:
  - Add a dedicated section to showcase more of my projects, including descriptions, technologies used, and links to live demos or repositories.

- **User Authentication**:
  - Integrate **Amazon Cognito** for user registration and login functionality, enabling personalized experiences.

- **Enhanced Cryptocurrency Tracker**:
  - Include additional metrics like market trends, historical data graphs, and support for multiple cryptocurrencies.

- **Serverless Workflow Orchestration**:
  - Explore **AWS Step Functions** to manage complex serverless workflows, such as multi-step data processing tasks.

- **Monitoring and Analytics**:
  - Implement monitoring using **AWS CloudWatch** and analytics with **Amazon QuickSight** to gain insights into user interactions.

- **Advanced CI/CD Pipeline**:
  - Enhance the CI/CD pipeline with automated testing, linting, and security checks using tools like **AWS CodePipeline** and **CodeBuild**.

---

Thank you for taking the time to explore my project! If you have any feedback or ideas for collaboration, I'd love to hear from you. Feel free to reach out via the contact information on my website.

---

# **Additional Notes**

## **Understanding CORS and Preflight Requests**

- **CORS Configuration**:
  - In the context of AWS Lambda and API Gateway, when using AWS_PROXY integrations, the Lambda function must handle CORS, including OPTIONS preflight requests.
- **Why OPTIONS Method Is Needed**:
  - Browsers send an OPTIONS request as a preflight check to determine if the actual request is safe to send.
  - The server must respond to the OPTIONS request with appropriate CORS headers.
- **Handling OPTIONS in Lambda**:
  - Modified Lambda functions to return a 200 response with necessary CORS headers when handling OPTIONS requests.

## **Terraform Best Practices**

- **Resource Comments**:
  - Included detailed comments in Terraform code to explain the purpose of configurations and any important considerations.
- **State Management**:
  - Considered setting up a separate S3 bucket and DynamoDB table for storing and locking Terraform state files in a collaborative environment.
- **Ignoring Unnecessary Files**:
  - Ensured that `.gitignore` includes directories and files that should not be tracked, such as `.terraform/` and `terraform.tfstate`.
- **Dependence Management**:
  - Recognized the importance of `depends_on` to manage resource creation order and prevent deployment issues.

---
