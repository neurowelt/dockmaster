import os
import time


if __name__ == '__main__':
    api_key = os.environ.get('API_KEY')
    print(f'API key: {api_key}')

    print('Worker is working...')
    for i in range(1, 11):
        time.sleep(1)
        print(f'Job done: {i}/10')
    print('Worker finished')
