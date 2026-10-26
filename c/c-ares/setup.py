from setuptools import setup

setup(
    name="c-ares",
    version="@VERSION@",
    packages=["c_ares"],
    package_data={"c_ares": ["**/*"]},
    include_package_data=True,
    license_files=["c_ares/LICENSE"],
)
