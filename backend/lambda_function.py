import boto3 # The AWS SDK for Python. It allows the Lambda function to interact with AWS services like DynamoDB in our case.
import os # Used to access environment variables (e.g., DYNAMODB_TABLE). 
import json # Used for handling JSON data, which is the standard format for event inputs and responses in Lambda. 

dynamodb = boto3.resource('dynamodb') # Creates a connection to DynamoDB using the default credentials and region configured for the Lambda function.
table_name = os.environ['DYNAMODB_TABLE'] # Fetches the name of the DynamoDB table (ViewerCountTable) from the environment variable defined in main.tf lambda function resource.
# Best approach instead of passing the name of the table through an event. We do it through the lambda resource created. 
table = dynamodb.Table(table_name) # Creates a reference (table) to the ViewerCountTable for performing operations like get_item and put_item.

def lambda_handler(event, context):
    # Define the primary key
    primary_key = "page_views" 

    # Increment viewer count
    try:
        # Get the current viewer count
        response = table.get_item(Key={'counter_id': primary_key})

        '''
        Example of a response: 
        {
        "Item": {
            "counter_id": "page_views",
            "view_count": 124
          }
        }

        DynamoDB retrieves the entire item by default once the primary key is provided.
        '''

        if 'Item' in response and 'view_count' in response['Item']:
            current_count = int(response['Item']['view_count'])
        else:
            current_count = 0

        '''
        We need to use int() before response['Item']['view_count'] because DynamoDB represents numeric values as Decimal objects, not as native Python integers or floats. 
        Always convert numeric values retrieved from DynamoDB to int (or float if decimal precision is required) to avoid issues. 
        Decimals are used for all numeric values in DynamoDB and are not directly compatible with int or float. 

        Ensure Compatibility with JSON Serialization: When you return the current_count as part of the response body, it needs to be JSON-serializable. 
        Native Python types (e.g., int, float) work with json.dumps(), but Decimal objects do not.

        Ensure Correct Arithmetic Operations: While Decimal supports arithmetic, converting to int ensures consistency in cases where you expect whole numbers.

        Ensure Correct Arithmetic Operations: While Decimal supports arithmetic, converting to int ensures consistency in cases where you expect whole numbers.

        x = Decimal('0.1')
        y = Decimal('0.2')
        print(x + y)  # 0.3 (exact)     

        int
        x = 1
        y = 2
        print(x + y)  # 3

        With float (similar to Decimal but less precise):
        x = 0.1
        y = 0.2
        print(x + y)  # 0.30000000000000004 (imprecision)

        Decimal is designed for precision but is slower.
        int is faster and simpler but cannot handle fractions.

        DynamoDB uses Decimal for all numeric data to avoid:

        Precision Errors: Ensures fractional or high-precision values are stored and retrieved exactly.
        Flexibility: Handles both whole numbers and decimals seamlessly.    
        '''

        # Increment the count
        new_count = current_count + 1 # Increment the count for this lambda invocation. 

        # Update the count in DynamoDB
        table.put_item(Item={'counter_id': primary_key, 'view_count': new_count}) # Puts the new count back to the table
        
        '''
        Why Do We Need to Specify Both Keys for put_item?
        put_item creates or replaces an entire item in a DynamoDB table.
        When you use put_item, you must specify:
        Primary Key (e.g., counter_id): Uniquely identifies the item.
        Attributes (e.g., view_count): All the attributes of the item you want to store.

        Item: Represents the full row (or item) to be stored in the table.
        DynamoDB does not "merge" new attributes into an existing item. 
        If you only specify the primary key in put_item, the item will replace the existing one, potentially deleting all other attributes.
        
        If the item contained: 
        {
        "counter_id": "page_views",
        "view_count": 10,
        "extra_attribute": "example"
        }

        And we run: table.put_item(Item={'counter_id': 'page_views', 'view_count': 20})

        We'll get: 

        {
        "counter_id": "page_views",
        "view_count": 20
        }

        The extra_attribute is removed because put_item replaces the entire item.
        
        put_ite	replaces the entire item, so all attributes need to be explicitly specified.
        '''

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET,OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization'
            },
            'body': json.dumps({'message': 'View count updated', 'view_count': new_count})
        }
    
    except Exception as e:
        
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET,OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization'
            },
            'body': json.dumps({'error': str(e)})
        }
