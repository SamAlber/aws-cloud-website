# AWS Resume Website

![Architecture](https://github.com/SamAlber/aws-cloud-website/blob/0333a39a1cc42b3d5a38c1952200d7f882cad749/website/assets/imgs/architecture.png)

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

#### **Cryptocurrency API Integration**:

- **Lambda Function**:
  - Developed a Lambda function in **Python** to fetch current cryptocurrency prices from an external API like CoinGecko or CryptoCompare.
  - Implemented error handling to manage API rate limits and network issues.

- **API Gateway Configuration**:
  - Set up REST endpoints that trigger the Lambda function.
  - Enabled caching in API Gateway to optimize performance and reduce costs.

- **Frontend Integration**:
  - The frontend makes asynchronous calls to the API endpoint to display real-time cryptocurrency prices and logos.

#### **CV Request Feature**:

- **Lambda Function**:
  - Validates user email addresses using regex patterns and AWS SES verification.
  - Generates signed URLs using **CloudFrontSigner** along with the **RSA utility** in Python for secure, time-limited access to the CV stored in S3.

- **AWS SES Setup**:
  - Configured SES to send emails from a verified domain.
  - Implemented email templates for consistent communication.

- **Security Measures**:
  - Stored email templates and sensitive configurations in AWS SSM Parameter Store.
  - Used IAM roles with least privilege principles for Lambda functions.

#### **Visitor Counter**:

- **Lambda Function**:
  - Reads and updates the visitor count in a DynamoDB table.
  - Ensures atomic operations to prevent read/write conflicts.

- **DynamoDB Configuration**:
  - Set up with a primary key for efficient data retrieval.
  - Configured auto-scaling to handle varying levels of traffic.

- **Frontend Display**:
  - The visitor count is fetched and updated in real-time on the website.

### **3. Infrastructure Automation**

- **Terraform Configuration**:
  - Wrote Terraform scripts to define AWS resources like S3 buckets, Lambda functions, API Gateway, DynamoDB tables, and IAM roles.
  - Used Terraform modules for reusability and organized code.

- **Resource Dependency Management**:
  - Employed `depends_on` attributes to manage resource creation order.
  - Used Terraform state files to track resource changes over time.

- **Version Control**:
  - Stored Terraform code in a Git repository for versioning and collaboration.

### **4. Continuous Integration and Deployment (CI/CD)**

- **GitHub Actions**:
  - Set up workflows to automatically deploy the frontend website to the S3 bucket whenever changes are pushed to the Git repository.
  - Configured actions to build, test, and deploy code, ensuring a streamlined development process.

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
  - The **public key** can be distributed openly, while the **private key** must be kept secure.
  - Data encrypted with the public key can only be decrypted with the private key and vice versa.

- **CloudFrontSigner and RSA in Python**:
  - In the Lambda function for the CV Request Feature, I used **CloudFrontSigner** from the `aws-cloudfront-sign` module.
  - The `CloudFrontSigner` requires an RSA private key to generate signed URLs.
  - The **rsa** Python library is used to load and manage the RSA private key within the code.

- **Generating Signed URLs**:
  - The Lambda function uses the RSA private key to sign a policy that includes the URL, expiration time, and access restrictions.
  - The **rsa** library handles the cryptographic signing process, ensuring the integrity and authenticity of the signed URL.
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
   - You enter your email address and submit the request.

2. **API Call**:
   - The frontend sends a POST request containing your email to the API Gateway.

3. **Lambda Function Workflow**:
   - **Email Validation**: Ensures the email is in a correct format.
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

### **1. Integrating GitHub Actions for CI/CD**

- **Challenge**:
  - Needed to automate the deployment process to ensure that any changes to the frontend code are reflected on the live website without manual intervention.

- **Solution**:
  - Implemented **GitHub Actions** workflows that trigger on pushes to the main branch.
  - Configured the workflow to build and upload the website files to the S3 bucket, invalidating CloudFront cache as necessary.

### **2. Using RSA with CloudFrontSigner in Python**

- **Challenge**:
  - Generating signed URLs for CloudFront required correctly implementing RSA signing in the Lambda function.

- **Solution**:
  - Used the **rsa** Python library to load the private key and sign the URL policy.
  - Ensured the private key was in the correct PEM format and securely stored in AWS SSM Parameter Store.
  - Integrated **CloudFrontSigner** with the **rsa** utility to generate valid signed URLs.

### **3. Understanding RSA Encryption in CloudFront Signed URLs**

- **Challenge**:
  - Needed to understand how RSA encryption works in the context of CloudFront signed URLs to implement secure access.

- **Solution**:
  - Studied the RSA algorithm and how it applies to signing data.
  - Learned that CloudFront uses the RSA public-private key pair to verify that a signed URL or signed cookie hasn't been tampered with.
  - Implemented the signing process in the Lambda function using the RSA private key, while CloudFront uses the corresponding public key to validate the signature.

### **4. Handling CORS Issues**

- **Challenge**:
  - The browser blocked API requests due to missing or incorrect CORS headers.

- **Solution**:
  - Configured CORS in API Gateway by enabling CORS on resource methods.
  - Updated Lambda functions to include `Access-Control-Allow-Origin` headers.

### **5. Resolving CloudFront and S3 Access Denied Errors**

- **Challenge**:
  - Encountered "Access Denied" errors when CloudFront tried to access S3 objects.

- **Solution**:
  - Implemented **CloudFront Origin Access Control (OAC)**.
  - Updated S3 bucket policies to allow access from the CloudFront OAC principal.
  - Ensured public access to the S3 bucket was blocked.

### **6. Managing Terraform Resource Dependencies**

- **Challenge**:
  - Deployment errors due to resources being created out of order.

- **Solution**:
  - Used the `depends_on` attribute in Terraform resource blocks.
  - Organized Terraform code into modules.
  - Ran `terraform plan` before applying changes.

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