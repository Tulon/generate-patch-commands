# Copyright 2016-2022 Joseph Artsimovich
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


find_package(Git)

find_program(
    PATCH_EXECUTABLE patch
    HINTS "${GIT_EXECUTABLE}/../../usr/bin"
    DOC "Full path to the patch executable"
)

if (NOT PATCH_EXECUTABLE)
    message(
        FATAL_ERROR
        "Unable to find the patch program. On Windows, the recommended version is the one "
        "that ships with the Git distribution. You may need to set the PATCH_EXECUTABLE "
        "variable manually to point to the path executable."
    )
endif()

# This command is intended to be used with the ExternalProject_Add() command.
# Generates a series of COMMAND sequences to be passed to ExternalProject_Add() or
# ExternalProject_Add_Step().
#
# Usage:
#     generate_patch_commands(
#         <output var> [USE_GIT_AM] PATCHES /path/to/patches/*.patch [more patches])
#
# Typical usage scenario:
#     generate_patch_commands(
#         patch_commands USE_GIT_AM PATCHES "${CMAKE_CURRENT_SOURCE_DIR}/patches/*.patch"
#     )
#     ExternalProject_Add(
#         ...
#         PATCH_COMMAND git reset --hard ${git_tag}
#         ${patch_commands}
#         ...
# )
#
function(generate_patch_commands out_var)

    cmake_parse_arguments(ARG "USE_GIT_AM" "" "PATCHES" ${ARGN})

    if(ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "generate_patch_commands(): unexpected arguments encountered")
    endif()

    set(commands "")

    if(ARG_USE_GIT_AM)
        list(
            APPEND commands
            COMMAND ${CMAKE_COMMAND} "-DGIT_EXECUTABLE=${GIT_EXECUTABLE}"
                -P "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/impl/set_git_user_if_unset.cmake"
        )
    endif()

    foreach(globbing_expr ${ARG_PATCHES})
        file(GLOB files LIST_DIRECTORIES false CONFIGURE_DEPENDS ${globbing_expr})
        list(SORT files)
        foreach(file ${files})
            if(ARG_USE_GIT_AM)
                list(APPEND commands COMMAND ${GIT_EXECUTABLE} am --3way ${file})
            else()
                list(APPEND commands COMMAND ${PATCH_EXECUTABLE} -p1 -f -i ${file})
            endif()
        endforeach()
    endforeach()

    set(${out_var} ${commands} PARENT_SCOPE)
endfunction()
