from setuptools import setup, find_packages

setup(
    name="mpc",
    version="@VERSION@",
    packages=find_packages(),
    package_data={"mpc": ["**/*"]},
    include_package_data=True,
    license_files=["mpc/LICENSE"],
)
