# Copyright (c) 2016 PaddlePaddle Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# NOTE: c-ares is needed when linking with grpc.

include (ExternalProject)

SET(CARES_SOURCES_DIR ${THIRD_PARTY_PATH}/cares)
SET(CARES_INSTALL_DIR ${THIRD_PARTY_PATH}/install/cares)
SET(CARES_INCLUDE_DIR "${CARES_INSTALL_DIR}/include/" CACHE PATH "cares include directory." FORCE)

if(NOT APPLE AND NOT WIN32)
    if(${CMAKE_CXX_COMPILER_VERSION} VERSION_GREATER 8.0)
        set(PATCH_COMMAND_CARES cp ${PADDLE_SOURCE_DIR}/patches/cares/ares_parse_ptr_reply.c.txt ${CARES_SOURCES_DIR}/src/extern_cares/ares_parse_ptr_reply.c)
    endif()
endif()

ExternalProject_Add(
    extern_cares
    GIT_REPOSITORY "https://github.com/c-ares/c-ares.git"
    GIT_TAG "cares-1_13_0"
    PREFIX          ${CARES_SOURCES_DIR}
    UPDATE_COMMAND  ""
    CONFIGURE_COMMAND ./buildconf && ./configure --disable-shared --prefix=${CARES_INSTALL_DIR}
    BUILD_IN_SOURCE 1
    PATCH_COMMAND ${PATCH_COMMAND_CARES}
    BUILD_COMMAND   make -j8
    INSTALL_COMMAND make install
)

ADD_LIBRARY(cares STATIC IMPORTED GLOBAL)
SET_PROPERTY(TARGET cares PROPERTY IMPORTED_LOCATION
             "${CARES_INSTALL_DIR}/lib/libcares.a")

include_directories(${CARES_INCLUDE_DIR})
ADD_DEPENDENCIES(cares extern_cares)
