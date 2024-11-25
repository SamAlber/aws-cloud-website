import json
import requests
import boto3


ssm = boto3.client('ssm') # Initializing the ssm client with boto3

def get_parameter(param_name):
    """
    Retrieve parameter from AWS Systems Manager Parameter Store.
    """
    try:
        response = ssm.get_parameter(Name=param_name, WithDecryption=True) # WithDecryption=True: If the parameter is encrypted (e.g., stored as a "SecureString"), this flag ensures the value is decrypted before returning it. 
        return response['Parameter']['Value'] # Extracts and returns the actual value of the parameter (e.g., "my-secret-value").
    except Exception as e:
        print(f"Error retrieving parameter {param_name}: {str(e)}")
        raise e # raise e re-raises the exception e that was caught in the except block. It propagates the exception to higher-level code, so it can handle it or terminate the program. 
    
'''
        Why raise is Needed:
        Preserve Original Error Information:

        Re-raising allows the original exception to bubble up the call stack, retaining the original error details (type, message, and traceback).
        This is crucial for debugging and understanding the root cause of the error.
        Log and Re-Throw:

        Often, exceptions are logged locally (e.g., logger.error) before being re-raised, ensuring you record what went wrong without suppressing the error.
        Avoid Masking Errors:

        If you handle an exception without re-raising it, the code might proceed in an unintended state or hide critical failures.

        def divide_numbers(a, b):
            try:
                return a / b
            except ZeroDivisionError as e:
                print(f"Error: Division by zero is not allowed. Details: {e}")
                raise e  # Re-raise the exception

        try:
            divide_numbers(5, 0)
        except ZeroDivisionError as e:
            print("Caught the error in the main function!")
        |
        v
        Error: Division by zero is not allowed. Details: division by zero
        Caught the error in the main function!
        Traceback (most recent call last):
        File "<stdin>", line 2, in divide_numbers
        ZeroDivisionError: division by zero

        If you don’t use raise e, only the log message (Logging error: division by zero) would be shown, and the original exception would be lost.

        def database_query(query):
            try:
                if query == "SELECT * FROM table":
                    raise TimeoutError("Database took too long to respond.")
            except TimeoutError as e:
                print("Logging the timeout issue.")
                raise e  # Re-raise the exception for higher-level handling

        def main():
            try:
                database_query("SELECT * FROM table")
            except TimeoutError as e:
                print("Alert: Database is currently unavailable.")

        main()

        Logging the timeout issue.
        Alert: Database is currently unavailable.
'''


def lambda_handler(event, context):
    # API endpoint and key
    url = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest"
    try:
        api_key = get_parameter('/lambda/market_cap_api_token')  # Store the key securely in environment variables (Stored in SSM in crypto_api.tf)
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET,OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization'
            },
            'body': json.dumps({'error': f"Failed to retrieve API key: {str(e)}"}) # Uses json.dumps to convert the prices dictionary into a JSON string for returning.  
        }
    


    # Extract the symbols to fetch (BTC, ETH, etc.)
    symbols = event.get('queryStringParameters', {}).get('symbols', 'BTC,ETH')
    
    '''
    # The event object is typically a dictionary containing information about an incoming HTTP request in an AWS Lambda function.
    # The get method is used to safely fetch the value associated with the key 'queryStringParameters'.
    # If this key doesn’t exist in event, the method will return the default value, {} (an empty dictionary), instead of raising a KeyError.

    Example 1: If event looks like this:

    event = {
    "queryStringParameters": {
        "symbols": "BTC,ETH"
        }
    }

    Then, event.get('queryStringParameters', {}) will return: {"symbols": "BTC,ETH"}

    Example 2: If event does not contain the 'queryStringParameters' key:

    event = {}

    Then, event.get('queryStringParameters', {}) will return: {}

    .get('symbols', 'BTC,ETH'):
    After ensuring that 'queryStringParameters' is a dictionary (or a default empty one), we use get again to retrieve the value associated with the key 'symbols'.

    If 'symbols' exists, its value will be returned.

    If 'symbols' doesn’t exist, the default value 'BTC,ETH' is returned. : {"symbols": "BTC,ETH"}

    If 'symbols' doesn’t exist, the default value 'BTC,ETH' is returned. : "BTC,ETH"  # Default value

    What Happens When the API is Called (why do we need it?)
    The symbols string is sent to the API as part of the request.
    If symbols is 'BTC,ETH' (default), the program fetches prices for Bitcoin and Ethereum.

    raise e:

    Re-raises the original exception, ensuring error propagation and debugging visibility.
    Used when you want to log the error but still fail gracefully.
    Defaulting to 'BTC,ETH':

    Provides a fallback to ensure the program works even when the client doesn’t specify symbols.
    It's a practical choice for a cryptocurrency API where Bitcoin and Ethereum are likely of interest.
    You can change this behavior to return an error if symbols are mandatory.

    '''

    # Request parameters
    params = {
        'symbol': symbols,
        'convert': 'USD'
    }

    headers = { # a dictionary that stores HTTP headers, which are metadata sent along with an HTTP request. 
                # Headers typically include details such as the type of content, authorization credentials, and other information required by the server.
        'X-CMC_PRO_API_KEY': api_key # A custom HTTP header. In this case, is specific to the CoinMarketCap API, and the X-CMC_PRO_API_KEY header is used to pass an API key for authentication.
    }

    # Call the API
    try:
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()  # Raise an error for HTTP issues
        data = response.json()
    except requests.RequestException as e:
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET,OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization'
            },
            'body': json.dumps({'error': f"HTTP request failed: {str(e)}"})
        }
    '''
        requests.get: Sends an HTTP GET request to the specified API endpoint (url).

        headers=headers: Includes authentication and metadata required by the API (e.g., the X-CMC_PRO_API_KEY header).

        params=params: Contains additional parameters to pass with the API request, such as filtering data (e.g., specific cryptocurrencies, price data).

        response.json(): Converts the JSON response from the API into a Python dictionary for easier processing.
    '''

    # Parse the required information
    try:
        prices = {
            symbol: data['data'][symbol]['quote']['USD']['price']
            for symbol in symbols.split(',') # symbols.split(',')  # Example: "BTC,ETH" -> ["BTC", "ETH"], Splits the symbols string (e.g., "BTC,ETH") into a list of individual symbols
            if symbol in data['data']
        }
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET,OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization'
            },
            'body': json.dumps({'prices': prices}) # Uses json.dumps to convert the prices dictionary into a JSON string for returning. 
        }
    except KeyError as e:
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET,OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization'
            },
            'body': json.dumps({'error': f"Data parsing failed: {str(e)}"})
        }
        
'''
        data['data']: Access the main data object in the response.

        [symbol]: Fetch details for the specific cryptocurrency (e.g., "BTC" or "ETH").

        ['quote']['USD']['price']: Access the price in USD.

        Example:

        data = {
            "data": {
                "BTC": {
                    "quote": {
                        "USD": {
                            "price": 30000.45
                        }
                    }
                },
                "ETH": {
                    "quote": {
                        "USD": {
                            "price": 2000.15
                        }
                    }
                }
            }
        }
        symbols = "BTC,ETH,LTC"

        Iterates over each symbol in the list generated by symbols.split(',').
        For each symbol:
        Checks if the symbol exists in data['data'].
        If it does:
        Uses symbol as the key.
        Retrieves the price for that symbol (data['data'][symbol]['quote']['USD']['price']) as the value.

        if symbol in data['data']

        This ensures the code only tries to access prices for symbols that actually exist in data['data'].
        Without this check, trying to access a nonexistent key (e.g., data['data']['LTC']) would raise a KeyError.

        Splits the symbols string into individual cryptocurrency symbols.
        Iterates over the list of symbols.
        Checks if each symbol exists in data['data'].
        If the symbol exists:
        Adds it to the prices dictionary with its price in USD.
        If any unexpected error occurs, the try block ensures the program doesn’t crash and allows for graceful handling.

        The symbol: part specifies what will be the key in the dictionary being created. Without it, Python would not know how to structure the key-value pairs.

'''
