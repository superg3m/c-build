import asyncio
import json

from .Compiler import Compiler
from .Project import Project
from .Utilities import (C_BUILD_IS_DEBUG, C_BUILD_IS_DEPENDENCY, \
                        C_BUILD_EXECUTION_TYPE, SET_MSVC_VARS_FROM_CACHE, FATAL_PRINT, FORMAT_PRINT,
                        C_BUILD_COMPILER_NAME)
class Manager:
    def __init__(self, compiler_config, project_config, procedures_config):
        self.compiler_config = compiler_config
        self.INTERNAL_COMPILER: Compiler = Compiler()
        self.INTERNAL_COMPILER.set_config(C_BUILD_IS_DEBUG(), compiler_config)
        if self.INTERNAL_COMPILER.compiler_name == "cl":
            SET_MSVC_VARS_FROM_CACHE()

        self.project_config = project_config
        self.procedures_config = procedures_config

    def build_project(self):
        if C_BUILD_IS_DEPENDENCY():
            serialized_name = f"c_build_dependency_cache_{C_BUILD_COMPILER_NAME()}.json"
            filtered_project_config = self.project_config.copy()
            filtered_project_config.pop("project_rebuild_project_dependencies", None)
            filtered_project_config.pop("project_debug_with_visual_studio", None)
            serialized_data = {
                **filtered_project_config,
                **self.procedures_config
            }
            with open(serialized_name, "w") as file:
                json.dump(serialized_data, file, indent=4)
            return


        project = Project(self.INTERNAL_COMPILER, self.project_config, self.procedures_config)
        project.build()