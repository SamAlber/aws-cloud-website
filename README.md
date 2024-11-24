# Cloud Resume Challenge

![Architecture](https://github.com/SamAlber/aws-cloud-website/blob/0333a39a1cc42b3d5a38c1952200d7f882cad749/website/assets/imgs/architecture.png)

## **Project Concept**

The Cloud Resume Challenge is a hands-on project designed to showcase modern cloud technologies, DevOps practices, and full-stack development skills. This project integrates AWS services, infrastructure automation, and frontend development to create a dynamic resume website with additional functionalities like a cryptocurrency price tracker and a visitor counter.

### **Key Features**

1. **Static Website Hosting**:
   - Hosted on **Amazon S3** with **CloudFront** as a Content Delivery Network (CDN).
   - **Cloudflare** is used for DNS management and SSL/TLS configuration.

2. **Dynamic Backend Functionalities**:
   - **Cryptocurrency Price Tracker**: Displays live cryptocurrency prices and logos.
   - **CV Request Feature**: Allows users to request a CV via email using **AWS SES** and CloudFront signed URLs for secure downloads.
   - **Visitor Counter**: Tracks and displays the number of visitors using **DynamoDB** and Lambda.

3. **Infrastructure as Code**:
   - All resources provisioned and managed using **Terraform**, ensuring consistency and scalability.

4. **Security**:
   - **CloudFront Origin Access Control (OAC)** restricts S3 bucket access.
   - Sensitive data is securely stored in **AWS Systems Manager Parameter Store**.

5. **Frontend**:
   - Built with HTML, CSS, and JavaScript for an interactive user experience.

---

## **AWS Services Used**

- **S3**: Static website hosting.
- **CloudFront**: Content Delivery Network.
- **Cloudflare**: DNS and SSL/TLS.
- **Lambda**: Serverless backend for API and business logic.
- **API Gateway**: REST API for frontend-backend communication.
- **DynamoDB**: Data storage for the visitor counter.
- **SES**: Email service for CV requests.
- **ACM**: SSL/TLS certificates for secure communication.
- **SSM Parameter Store**: Secure storage for sensitive configurations.

---

## **Development Flow**

### **1. Frontend Development**

- Created a responsive static website with sections for an interactive resume, dynamic visitor counter, and cryptocurrency price tracker.
- Used JavaScript to fetch cryptocurrency data from an external API and display it dynamically.

### **2. Backend Implementation**

#### **Cryptocurrency API Integration**:
- Developed a Lambda function to fetch cryptocurrency prices.
- JavaScript calls the REST API via API Gateway to display real-time prices and logos.

#### **CV Request Feature**:
- Created a Lambda function to validate email addresses, generate CloudFront signed URLs for secure CV downloads, and send emails via SES.

#### **Visitor Counter**:
- Configured a Lambda function to update and retrieve visitor count stored in DynamoDB, ensuring consistent and dynamic updates.

### **3. Infrastructure Automation**

- Defined all AWS resources in Terraform to automate deployment.
- Configured **CloudFront OAC** for secure S3 access.
- Used `depends_on` in Terraform for resource dependency management.

---

## **User Flow**

### **1. Accessing the Website**

1. **Browser Request**:
   - User types `www.samuelalber.com` into their browser.
   - **Cloudflare** resolves the DNS query and forwards the request to **CloudFront**.

2. **CloudFront Processing**:
   - CloudFront identifies the requested content:
     - **Cached Content**: Served immediately from the nearest edge location.
     - **Uncached Content**: Fetched from the origin S3 bucket and then cached.

3. **Website Display**:
   - The static content (HTML, CSS, JavaScript) is served to the user’s browser.

### **2. Using Dynamic Features**

#### **Cryptocurrency Price Tracker**:
1. JavaScript fetches cryptocurrency data from the backend REST API.
2. API Gateway routes the request to the Lambda function.
3. Lambda fetches data from an external API and sends the response back to the frontend.
4. The frontend displays the prices and logos dynamically.

#### **CV Request**:
1. User enters their email and clicks “Receive My CV.”
2. The frontend sends a POST request with the email to the API Gateway.
3. API Gateway invokes the Lambda function using AWS_PROXY integration.
4. Lambda function:
   - Validates the email.
   - Generates a signed URL using CloudFrontSigner.
   - Sends the signed URL via SES to the user’s email.
5. User receives an email with the secure download link.

#### **Visitor Counter**:
1. JavaScript triggers a GET request to the visitor counter API.
2. API Gateway routes the request to a Lambda function.
3. Lambda function:
   - Updates the visitor count in DynamoDB.
   - Retrieves the current count and sends it back to the frontend.
4. The frontend displays the updated visitor count dynamically.

---

## **Challenges and Solutions**

### **1. CORS Issues**
- **Problem**: Browser blocked API requests due to CORS misconfigurations.
- **Solution**: Configured API Gateway to handle preflight OPTIONS requests and ensured proper headers were set in the Lambda responses.

### **2. CloudFront-S3 Integration**
- **Problem**: Access denied errors when retrieving S3 objects via CloudFront.
- **Solution**: Configured CloudFront OAC and updated S3 bucket policies for secure access.

### **3. Terraform Dependency Management**
- **Problem**: Resource deployment errors due to incorrect dependencies.
- **Solution**: Used `depends_on` attributes in Terraform configurations to establish clear resource dependencies.

### **4. Signed URL Generation**
- **Problem**: Generating time-limited secure links for CV downloads.
- **Solution**: Implemented CloudFrontSigner in Lambda to generate signed URLs.

---

## **Future Goals**

- Add a portfolio section to display completed projects.
- Integrate user authentication for enhanced security.
- Expand the cryptocurrency tracker to display more detailed data.
- Explore AWS Step Functions for orchestrating serverless workflows.

---

Thank you for exploring this project! Feedback and collaboration are always welcome. 🚀

---

