import json
from requests import Session

from utils import hash_func


if __name__ == "__main__":

    headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
    }

    with Session() as session:
        inferece_response = session.get(
            'http://localhost:5001/inference', headers=headers
        )
        training_response = session.get(
            'http://localhost:5002/training', headers=headers

        )

        assert inferece_response.status_code == 200, \
            f"Failed to retrieve response - error code {inferece_response.status_code}"
        assert training_response.status_code == 200, \
            f"Failed to retrieve response - error code {training_response.status_code}"
        
        inference_content = json.loads(inferece_response.content)['result']
        training_content = json.loads(training_response.content)['result']

        assert inference_content == hash_func('inference'), \
            'Inference should return the same value as provided hash.'
        assert training_content == hash_func('training'), \
            'Training should return the same value as provided hash.'
        