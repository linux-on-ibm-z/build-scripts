"""Package native aws-c-sdkutils .so files with a version-only Python module."""
import os
from pathlib import Path

from setuptools import Distribution, setup
from wheel.bdist_wheel import bdist_wheel


class NativeDistribution(Distribution):
    def has_ext_modules(self):
        return True


class NativePayloadWheel(bdist_wheel):
    def finalize_options(self):
        super().finalize_options()
        self.root_is_pure = False

    def get_tag(self):
        # py3-none-<platform> — ABI-independent native payload wheel
        return "py3", "none", super().get_tag()[2]


payload = Path("python_package/aws_c_sdkutils")
if not payload.is_dir():
    raise RuntimeError("Stage the native aws-c-sdkutils .so files before building")

setup(
    version=os.environ["AWS_C_SDKUTILS_VERSION"],
    packages=["aws_c_sdkutils"],
    package_dir={"": "python_package"},
    package_data={"aws_c_sdkutils": [
        p.relative_to(payload).as_posix()
        for p in sorted(payload.rglob("*")) if p.is_file()
    ]},
    include_package_data=False,
    distclass=NativeDistribution,
    cmdclass={"bdist_wheel": NativePayloadWheel},
    zip_safe=False,
)
