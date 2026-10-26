"""aws-c-sdkutils: Python package bundling the aws-c-sdkutils C library."""
from importlib.metadata import version as _version

__version__ = _version(__name__.replace("_", "-"))
del _version
