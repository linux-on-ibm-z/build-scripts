from setuptools import setup, find_packages

setup(
    name="mpfr",
    version="@VERSION@",
    packages=find_packages(),
    package_data={"mpfr": ["**/*"]},
    include_package_data=True,
    license_files=["LICENSE"],
)
