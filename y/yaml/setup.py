from setuptools import setup, find_packages

setup(
    name="yaml",
    version="@VERSION@",
    packages=find_packages(),
    package_data={"yaml": ["**/*"]},
    include_package_data=True,
    license_files=["yaml/LICENSE"],
)
