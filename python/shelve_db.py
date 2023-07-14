import shelve
from pathlib import Path

class ShelveDB:
    """
    Use shelve as simple DB.

    >>> db = ShelveDB()
    >>> db['example'] = 'Hello, world!'
    >>> db['example']
    'Hello, world!'
    """

    def __init__(self, location: str = None):
        self.location: str = str(Path.cwd())

    def __repr__(self) -> str:
        return f"{type(self).__name__} {self.location}"

    def __getitem__(self, key):
        with shelve.open(self.location, "c", writeback=True) as db:
            fetched_key = db.get(str(key), None)
            if not fetched_key:
                raise KeyError
            return fetched_key

    def __setitem__(self, key, value):
        with shelve.open(self.location, "c", writeback=True) as db:
            db[str(key)] = str(value)
