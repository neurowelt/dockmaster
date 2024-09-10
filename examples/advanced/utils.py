import hashlib


def hash_func(data: str) -> str:
    """
    Return sha256 hash of given string.

    Args:
        data (str): String data to be hashed

    Returns:
        str: Hex value of a hashed data string.
    """
    return hashlib.sha256(f"{data}".encode()).hexdigest()
