import os
import sys
from julia.api import Julia, JuliaInfo

libpython_msg = """
Python interpreter is statically linked to libpython.
Compilation cache will be disabled.
See https://pyjulia.readthedocs.io/en/latest/troubleshooting.html for more information.
""".strip()

script_dir = os.path.dirname(os.path.realpath(__file__))

info = JuliaInfo.load()
if not info.is_compatible_python():
    print(libpython_msg)
    Julia(compiled_modules=False)

from julia import Pkg
Pkg.activate(script_dir)

from julia import HDPHMM
sys.modules[__name__] = HDPHMM
