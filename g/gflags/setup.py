from setuptools import setup, find_packages
from setuptools.command.install import install
import os
from shutil import copytree


class InstallWithLibs(install):
    def run(self):
        install.run(self)
        lib_src = os.path.join(os.path.dirname(__file__), "gflags")
        lib_dst = os.path.join(self.install_lib, "gflags")
        copytree(lib_src, lib_dst, dirs_exist_ok=True)


setup(
    name="gflags",
    version="@VERSION@",
    packages=find_packages(),
    include_package_data=True,
    package_data={"gflags": ["LICENSE", "lib/*.so*", "include/gflags/*.h"]},
    cmdclass={"install": InstallWithLibs},
)
