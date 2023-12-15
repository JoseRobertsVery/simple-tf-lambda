import pandas as pd


def lambda_handler(event, context):
    message = 'Hello {} !'.format(event['key1'])
    d = {'col1': [1, 2], 'col2': [3, 4], 'col3': [5, 6]}
    df = pd.DataFrame(data=d)
    print(df.to_dict())
    return {
        'message' : message
    }
