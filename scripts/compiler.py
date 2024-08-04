# Configuration
# address sanitizers
# disable warnings
# inject into compiler args
# specify version of c
# have default specification
import os
from typing import List, Union, Dict

from scripts.globals import FORMAT_PRINT

# init compiler
# setup compiler arguments
# source files
# include paths
# additional libs
# additional libs paths
# compile time defines
# invoke compiler

#compilers to support
# gcc
# cl
# cc
# clang

# build with multi-threading!!!
# build with multi-threading!!!
# build with multi-threading!!!
# build with multi-threading!!!
# build with multi-threading!!!
# build with multi-threading!!!
# build with multi-threading!!!
# build with multi-threading!!!
# build with multi-threading!!!
# build with multi-threading!!!
# build with multi-threading!!!
# build with multi-threading!!! /MP /WX

from enum import Enum


class CompilerType(Enum):
    INVALID = -1
    CL = 0
    GCC_CC_CLANG = 1


class CompilerAction(Enum):
    NO_ACTION = -1
    STD_VERSION = 0
    NO_LOGO = 1
    OBJECTS_ONLY = 2
    COMPILE_TIME_DEFINES = 3
    OUTPUT = 4
    MULTI_THREADING = 5
    ADDRESS_SANITIZER = 6
    DISABLE_WARNINGS = 7
    DISABLE_SPECIFIC_WARNING = 8


compiler_lookup_table: List[List[str]] = [
    # Compiler CL
    [
        "/std:",  # STD_VERSION
        "/nologo",  # NO_LOGO
        "/c",  # OBJECT_FLAG
        "/Fe:",  # OUTPUT_FLAG
        "/D",  # COMPILE_TIME_DEFINE_FLAG
        "/MP",  # MULTI_THREADING
        "/fsanitize=address",  # ADDRESS_SANITIZER
        "/W0",  # DISABLE_WARNINGS
        "/wd"  # DISABLE_SPECIFIC_WARNING
    ],
    # Compiler GCC_CC_CLANG
    [
        "-std=",  # STD_VERSION
        None,  # NO_LOGO
        "-c",  # OBJECT_FLAG
        "-o",  # OUTPUT_FLAG
        "-D",  # COMPILE_TIME_DEFINE_FLAG
        "-j",  # MULTI_THREADING
        "-fsanitize=address",  # ADDRESS_SANITIZER
        "-w",  # DISABLE_WARNINGS
        "-Wno-"  # DISABLE_SPECIFIC_WARNING
    ],
]


class Compiler:
    def __init__(self, compiler_json, debug) -> None:
        # global
        self.compiler_type: str = compiler_json["compiler_type"]
        self.compiler_type_enum: CompilerType = CompilerType.INVALID
        self.compiler_action: CompilerAction = CompilerAction.NO_ACTION

        self.compiler_type_enum = self.choose_compiler_type()
        self.compiler_action: CompilerAction = CompilerAction.NO_ACTION

        self.std_version: str = compiler_json["std_version"]
        self.compiler_disable_warnings: List[str] = compiler_json["compiler_disable_warnings"]
        self.additional_libs: List[str] = compiler_json["additional_libs"]
        self.compiler_warning_level: str = compiler_json["compiler_warning_level"]
        self.compiler_treat_warnings_as_errors: bool = compiler_json["compiler_treat_warnings_as_errors"]
        self.compiler_inject_into_args = compiler_json["inject_as_argument"]
        self.compiler_disable_specific_warnings: List[str] = compiler_json["disable_specific_warnings"]
        self.debug: bool = debug

        # procedure specific
        self.output_name: str = ""
        self.compile_time_defines: List[str] = []
        self.should_build_executable: bool = False
        self.should_build_static_lib: bool = False
        self.should_build_dynamic_lib: bool = False
        self.source_files: List[str] = []
        self.include_paths: List[str] = []
        self.additional_libs: List[str] = []
        self.inject_into_args: List[str] = []

        self.compiler_arguments = ""

        # compiler type (cl, gcc, cc, clang)

    def setup_procedure(self, build_directory: str, procedure_json):
        self.output_name = procedure_json["output_name"]
        self.compile_time_defines = procedure_json["compile_time_defines"]

        self.should_build_executable: bool = False
        self.should_build_static_lib: bool = False
        self.should_build_dynamic_lib: bool = False

        extension: str = os.path.splitext(self.output_name)[-1].lower()
        if extension == ".exe":
            self.should_build_executable = True
        elif extension in [".lib", ".a"]:
            self.should_build_static_lib = True
        elif extension in [".so", ".o", ".dylib"]:
            self.should_build_dynamic_lib = True
        else:
            self.should_build_executable = True  # For Linux

        self.source_files = procedure_json["source_files"]
        self.include_paths = procedure_json["include_paths"]
        self.additional_libs = procedure_json["additional_libs"]

    def std_is_valid(self) -> bool:
        acceptable_versions: Dict[int, List[str]] = {
            0: ["c11", "c17", "clatest"],  # CL
            1: ["c89", "c90", "c99", "c11", "c17", "c18", "c23"],  # GCC_CC_CLANG
        }

        return self.std_version in acceptable_versions[self.compiler_type_enum.value]

    def choose_compiler_type(self):
        temp = CompilerType.INVALID
        if self.compiler_type == "cl":
            temp = CompilerType.CL
        elif self.compiler_type in ["gcc", "cc", "clang"]:
            temp = CompilerType.GCC_CC_CLANG
        return temp

    def set_action(self, action: CompilerAction):
        self.compiler_action = action

    def get_compiler_lookup(self) -> str:
        return compiler_lookup_table[self.compiler_type_enum.value][self.compiler_action.value]

    def invoke(self):
        compiler_command: List[str] = [self.compiler_type]

        for source in self.source_files:
            if source:
                compiler_command.append(source)

        # Add no logo flag
        self.set_action(CompilerAction.NO_LOGO)
        no_logo_flag = self.get_compiler_lookup()
        if no_logo_flag:
            compiler_command.append(no_logo_flag)

        # Add std version flag
        self.set_action(CompilerAction.STD_VERSION)
        std_version_flags = self.get_compiler_lookup()
        if self.std_is_valid():
            compiler_command.append(f"{std_version_flags}{self.std_version}")
        else:
            FORMAT_PRINT(f"Std version: {self.std_version} not supported, falling back on default")

        # Add compile time defines
        self.set_action(CompilerAction.COMPILE_TIME_DEFINES)
        compile_time_define_flag = self.get_compiler_lookup()
        for define in self.compile_time_defines:
            if define:
                compiler_command.append(f"{compile_time_define_flag}{define}")

        # Add object flag
        if self.should_build_static_lib:
            self.set_action(CompilerAction.OBJECTS_ONLY)
            object_flag = self.get_compiler_lookup()[
                CompilerAction.OBJECTS_ONLY.value]  # Get the object flag for the specific compiler
            compiler_command.append(object_flag)
        else:
            if self.should_build_dynamic_lib:
                dynamic_lib_flag = self.get_compiler_lookup()[
                    CompilerAction.OBJECTS_ONLY.value]  # Use the appropriate flag for dynamic libs
                if self.compiler_type == "cl":
                    compiler_command.append("/LD")  # Use CL-specific flag for dynamic libraries
                else:
                    compiler_command.append("-shared")  # Use common flag for GCC/CC/CLANG

            # Add output flag
            self.set_action(CompilerAction.OUTPUT)
            output_flag = self.get_compiler_lookup()[CompilerAction.OUTPUT.value]
            compiler_command.append(output_flag)
            compiler_command.append(self.output_name)

            if self.additional_libs:
                for lib in self.additional_libs:
                    if lib:
                        compiler_command.append(lib)

        # Add multi-threading flag
        self.set_action(CompilerAction.MULTI_THREADING)
        multi_threading_flag = self.get_compiler_lookup()
        compiler_command.append(multi_threading_flag)

        # Add address sanitizer flag
        self.set_action(CompilerAction.ADDRESS_SANITIZER)
        address_sanitizer_flag = self.get_compiler_lookup()
        compiler_command.append(address_sanitizer_flag)

        # Add disable warnings flag
        self.set_action(CompilerAction.DISABLE_WARNINGS)
        disable_warnings_flag = self.get_compiler_lookup()
        compiler_command.append(disable_warnings_flag)

        # Add disable specific warning flag
        self.set_action(CompilerAction.DISABLE_SPECIFIC_WARNING)
        disable_specific_warning_flag = self.get_compiler_lookup()
        for warning in self.compiler_disable_specific_warnings:
            compiler_command.append(f"{disable_specific_warning_flag}{warning}")

        # Add warnings as errors flag
        if self.compiler_treat_warnings_as_errors:
            if self.compiler_type_enum == CompilerType.CL:
                compiler_command.append("/WX")
            else:
                compiler_command.append("-Werror")

        # Add optimization flag
        if self.debug:
            if self.compiler_type_enum == CompilerType.CL:
                compiler_command.append("/Od")
                compiler_command.append("/Zi")
            else:
                compiler_command.append("-g")
        else:
            if self.compiler_type_enum == CompilerType.CL:
                compiler_command.append("/O2")
            else:
                compiler_command.append("-O2")

        # Add include paths
        for include_path in self.include_paths:
            if include_path:
                if self.compiler_type_enum == CompilerType.CL:
                    compiler_command.append(f"/I{include_path}")
                else:
                    compiler_command.append(f"-I{include_path}")

        # Add additional compiler flags
        for flag in self.compiler_inject_into_args:
            if flag:
                compiler_command.append(flag)