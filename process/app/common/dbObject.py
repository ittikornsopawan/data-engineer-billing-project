from collections import namedtuple

def convertToObject(rows, cursor):
    """Convert query results to an object-like structure."""
    columns = [desc[0] for desc in cursor.description]  # Column names
    RowObject = namedtuple("RowObject", columns)  # Create a namedtuple class

    return [RowObject(*row) for row in rows]