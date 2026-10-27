from setuptools import setup

setup(
    name="leveldb",
    version="@VERSION@",
    packages=["leveldb"],
    package_data={"leveldb": ["**/*"]},
    include_package_data=True,
    license_files=["leveldb/LICENSE"],
)
