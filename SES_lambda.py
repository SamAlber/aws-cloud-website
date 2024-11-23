import boto3
import json
import os
import re
from datetime import datetime, timedelta
import logging
from botocore.signers import CloudFrontSigner
import rsa

# Initialize AWS clients
ses = boto3.client('ses')
ssm = boto3.client('ssm')

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def is_valid_email(email):
    """
    Validate the format of an email address.
    """
    regex = r'^[\w\.-]+@[\w\.-]+\.\w+$'
    return re.match(regex, email) is not None

def get_parameter(param_name):
    """
    Retrieve parameter from AWS Systems Manager Parameter Store.
    """
    try:
        response = ssm.get_parameter(Name=param_name, WithDecryption=True)
        return response['Parameter']['Value']
    except Exception as e:
        logger.error(f"Error retrieving parameter {param_name}: {str(e)}")
        raise e

def rsa_signer(message):
    """
    Signer function for CloudFrontSigner.
    """
    private_key_pem = get_parameter('/cloudfront/private_key')
    private_key = rsa.PrivateKey.load_pkcs1(private_key_pem.encode('utf-8'))
    return rsa.sign(message, private_key, 'SHA-1')

def generate_signed_url(url, key_pair_id, expiration_minutes=60):
    """
    Generate a CloudFront pre-signed URL using CloudFrontSigner.
    """
    cloudfront_signer = CloudFrontSigner(key_pair_id, rsa_signer)
    expire_date = datetime.utcnow() + timedelta(minutes=expiration_minutes)
    signed_url = cloudfront_signer.generate_presigned_url(
        url, date_less_than=expire_date
    )
    return signed_url

def lambda_handler(event, context):
    """
    Handle the Lambda invocation for sending the CV link.
    """

    # Log the incoming event for debugging
    logger.info(json.dumps(event))

    # Handle CORS preflight (OPTIONS request) # important for the receive CV button 
    if event.get('httpMethod') == 'OPTIONS':
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",  # Replace "*" with your domain if needed
                "Access-Control-Allow-Methods": "POST,OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type,Authorization",
            },
            "body": json.dumps({"message": "CORS preflight request success"})
        }
    
    # Extract the email address from the event
    try:
        recipient_email = json.loads(event['body'])['email']
    except (KeyError, json.JSONDecodeError, TypeError) as e:
        logger.error(f"Invalid input format: {str(e)}")
        return {
            "statusCode": 400,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST,OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type,Authorization"
            },
            "body": json.dumps({"error": "Invalid input format. Expected a JSON with 'email' key."})
        }

    sender_email = os.environ['SENDER_EMAIL']
    cloudfront_url = os.environ['CLOUDFRONT_URL']

    # Retrieve parameters from Parameter Store
    try:
        private_key_pem = get_parameter('/cloudfront/private_key')
        key_pair_id = get_parameter('/cloudfront/key_pair_id')
    except Exception as e:
        logger.error(f"Failed to retrieve parameters: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST,OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type,Authorization"
            },
            "body": json.dumps({"error": f"Failed to retrieve parameters: {str(e)}"})
        }

    # Validate email address
    if not recipient_email or not is_valid_email(recipient_email):
        logger.error("Invalid email address")
        return {
            "statusCode": 400,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST,OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type,Authorization"
            },
            "body": json.dumps({"error": "Invalid email address"})
        }

    # Generate the pre-signed URL for the CV
    try:
        signed_url = generate_signed_url(cloudfront_url, key_pair_id)
    except Exception as e:
        logger.error(f"Failed to generate pre-signed URL: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST,OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type,Authorization"
            },
            "body": json.dumps({"error": f"Failed to generate pre-signed URL: {str(e)}"})
        }

    # Compose the email
    subject = "Your Requested CV"
    body_text = (
        f"Dear User,\n\n"
        f"Please find your requested CV at the following link:\n{signed_url}\n\n"
        f"Note: This link will expire in 1 hour.\n\n"
        f"Best regards,\nSamuel Albershtein"
    )

    # Send email using SES
    try:
        ses.send_email(
            Source=sender_email,
            Destination={"ToAddresses": [recipient_email]},
            Message={
                "Subject": {"Data": subject},
                "Body": {"Text": {"Data": body_text}}
            }
        )
        logger.info("Email sent successfully")
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST,OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type,Authorization"
            },
            "body": json.dumps({"message": "Email sent successfully!"})
        }
    except Exception as e:
        logger.error(f"Failed to send email: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST,OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type,Authorization"
            },
            "body": json.dumps({"error": f"Failed to send email: {str(e)}"})
        }
