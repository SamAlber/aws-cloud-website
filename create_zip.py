import zipfile

with zipfile.ZipFile('viewer_count.zip', 'w') as z:
    z.write('lambda_function.py') # .write() is a method of the class ZipFile imported from zipfile module 


with zipfile.ZipFile('SES_lambda.zip', 'w') as z:
    z.write('SES_lambda.py') # .write() is a method of the class ZipFile imported from zipfile module 

    
