from setuptools import setup, find_packages
from setuptools.command.install import install
import os
from shutil import copytree


class InstallWithLibs(install):
    def run(self):
        install.run(self)
        lib_src = os.path.join(os.path.dirname(__file__), "gmp")
        lib_dst = os.path.join(self.install_lib, "gmp")
        copytree(lib_src, lib_dst, dirs_exist_ok=True)


setup(
    name="gmp",
    version="@VERSION@",
    packages=find_packages(),
    include_package_data=True,
    package_data={"gmp": ["include/**/*", "lib/*", "lib64/*", "LICENSE"]},
    license_files=["gmp/LICENSE"],
    cmdclass={"install": InstallWithLibs},
)
