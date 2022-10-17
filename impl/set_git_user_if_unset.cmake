# Copyright 2022 FATMAP
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

if(NOT DEFINED GIT_EXECUTABLE)
    message(FATAL_ERROR "GIT_EXECUTABLE is not defined")
endif()

execute_process(
    COMMAND ${GIT_EXECUTABLE} config --get user.name
    RESULT_VARIABLE user_name_res
)

execute_process(
    COMMAND ${GIT_EXECUTABLE} config --get user.email
    RESULT_VARIABLE user_email_res
)

if(NOT (user_name_res EQUAL 0 AND user_email_res EQUAL 0))
    # Set a fake git user for the local repository, just to make applying patches possible.
    execute_process(
        COMMAND ${GIT_EXECUTABLE} config user.name "Auto Patcher"
        COMMAND ${GIT_EXECUTABLE} config user.email "auto.patcher@no-such-domain"
        COMMAND_ERROR_IS_FATAL ANY
    )
endif()
