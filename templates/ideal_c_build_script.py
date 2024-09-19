# -------------------------------- GENERATED BY C_BUILD --------------------------------
import argparse
import os

from c_build.new_stuff.globals import *
from c_build.new_stuff.new_project import *

parser = argparse.ArgumentParser(description='c_build_script')
parser.add_argument('--build_type', type=str, required=True, help='Build type (e.g. cl, gcc, cc, clang)')
parser.add_argument('--compiler', type=str, required=True, help='Build type (e.g. debug, release)')
parser.add_argument('--mode', type=str, required=True, help='Build type (e.g. BUILD, DEBUGGER, CLEAN)')
args = parser.parse_args()
COMPILER = args.compiler
BUILD_TYPE = args.build_type
MODE = args.mode
# --------------------------------------------------------------------------------------

project = Project("ckg", COMPILER)

# Do different things depending on the platform
if COMPILER == "cl":
	project.set_compiler_warning_level("2")
	project.disable_specific_warnings(["5105", "4668", "4820"])
elif COMPILER in ["gcc", "cc", "clang"]:
	project.set_compiler_warning_level("all")

project.set_treat_warnings_as_errors(True)
project.set_debug_with_visual_studio(True)
project.set_rebuild_project_dependencies(True)

project.set_project_dependencies([""])
# -------------------------------------------------------------------------------------
procedures = {
    "something_lib": {
        "build_directory": f"./build_{COMPILER}",
        "output_name": "ckit.lib" if COMPILER == "cl" else "libckit.a",
        "source_files": ["../ckg/ckg.c", "../ckit.c"],
        "additional_libs": [] if COMPILER == "cl" else ["-lUser32", "-lGDI32"],
        "compile_time_defines": [],
        "include_paths": [],
    },
    "something_test": {
        "build_directory": f"./Tests/CoreTest/build_{COMPILER}",
        "output_name": "ckit_test.exe" if COMPILER == "cl" else "ckit_test",
        "source_files": ["../*.c"],
        "additional_libs": [f"../../../build_{COMPILER}/ckit.lib" if COMPILER == "cl" else f"../../../build_{COMPILER}/libckit.a"],
        "compile_time_defines": [],
        "include_paths": [],
    },
}

for procedure_name, procedure_data in procedures.items():
	procedure = project.add_procedure(procedure_data["build_directory"])
	procedure.set_output_name(procedure_data["output_name"])
	procedure.set_source_files(procedure_data["source_files"])
	procedure.set_include_paths(procedure_data["include_paths"])
	procedure.set_compile_time_defines(procedure_data["compile_time_defines"])
	procedure.set_additional_libs(procedure_data["additional_libs"])
# -------------------------------------------------------------------------------------
project.set_executables_to_run(["test_ckg.exe"])

project.build(MODE, BUILD_TYPE)