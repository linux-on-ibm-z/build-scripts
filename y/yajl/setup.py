from setuptools import setup, find_packages

setup(
    name="yajl",
    version="@VERSION@",
    packages=find_packages(),
    package_data={"yajl": ["**/*"]},
    include_package_data=True,
    license="ISC",
)
