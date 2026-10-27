"""aws-c-common: Python package bundling the aws-c-common C library."""
from importlib.metadata import version as _version

__version__ = _version(__name__.replace("_", "-"))
del _version
