from setuptools import setup

setup(
    name="libssh2",
    version="@VERSION@",
    packages=["libssh2"],
    package_data={"libssh2": ["**/*"]},
    include_package_data=True,
)
