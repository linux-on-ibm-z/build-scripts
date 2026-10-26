from setuptools import setup, find_packages

setup(
    name="zeromq",
    version="@VERSION@",
    description="ZeroMQ native library wheel for s390x",
    packages=find_packages(),
    package_data={
        "zeromq": [
            "**/*",
        ],
    },
    include_package_data=True,
    zip_safe=False,
    license_files=["zeromq/LICENSE"],
)
