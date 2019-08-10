# ****************************************************************************
#  Project:  LibCMaker_FontConfig
#  Purpose:  A CMake build script for FontConfig library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2018 NikitaFeodonit
#
#    This file is part of the LibCMaker_FontConfig project.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.
# ****************************************************************************

cmake_minimum_required(VERSION 3.4)

project(LibCMaker_FontConfig_Compile_Test CXX C)

option(CMAKE_VERBOSE_MAKEFILE "CMAKE_VERBOSE_MAKEFILE" OFF)
option(cmr_PRINT_DEBUG "cmr_PRINT_DEBUG" OFF)


#-----------------------------------------------------------------------
# Configure to find_package()
#-----------------------------------------------------------------------

# Set CMake's search path for find_*() commands.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(ANDROID OR IOS)
  list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
endif()


#-----------------------------------------------------------------------
# Set path vars
#-----------------------------------------------------------------------

set(LibCMaker_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/libs")
set(cmr_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}")

if(NOT cmr_UNPACKED_DIR)
  set(cmr_UNPACKED_DIR "${PROJECT_BINARY_DIR}/download/unpacked")
endif()


#-----------------------------------------------------------------------
# LibCMaker settings
#-----------------------------------------------------------------------

set(LibCMaker_DIR "${LibCMaker_LIB_DIR}/LibCMaker")
list(APPEND CMAKE_MODULE_PATH "${LibCMaker_DIR}/cmake")
include(cmr_find_package)


#-----------------------------------------------------------------------
# Download, configure, build, install and find the required libraries
#-----------------------------------------------------------------------

option(BUILD_TESTING "Build the testing tree." OFF)
if(BUILD_TESTING)
  enable_testing()
  include(${LibCMaker_LIB_DIR}/LibCMaker_GoogleTest/cmr_build_googletest.cmake)
endif()

if(MSVC)
  include(${LibCMaker_LIB_DIR}/LibCMaker_Dirent/cmr_build_dirent.cmake)
endif()
include(${LibCMaker_LIB_DIR}/LibCMaker_Expat/cmr_build_expat.cmake)
include(
  ${LibCMaker_LIB_DIR}/LibCMaker_FreeType/cmr_build_freetype_with_harfbuzz.cmake
)
include(${LibCMaker_LIB_DIR}/LibCMaker_FontConfig/cmr_build_fontconfig.cmake)


#-----------------------------------------------------------------------
# Build the executable of the example
#-----------------------------------------------------------------------

set(lib_SRC_DIR
  "${cmr_UNPACKED_DIR}/fontconfig-${FONTCONFIG_lib_VERSION}/fontconfig-${FONTCONFIG_lib_VERSION}"
)

if(MSVC)
  set(example_src_DIR "${CMAKE_CURRENT_LIST_DIR}/src")
else()
  set(example_src_DIR "${lib_SRC_DIR}/fc-list")
endif()

add_executable(${PROJECT_NAME}
  ${example_src_DIR}/fc-list.c
)
set_target_properties(${PROJECT_NAME} PROPERTIES
  CXX_STANDARD 11
  C_STANDARD 11
)


#-----------------------------------------------------------------------
# Link to the libraries
#-----------------------------------------------------------------------

# FontConfig
target_include_directories(${PROJECT_NAME} PRIVATE ${FONTCONFIG_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PRIVATE ${FONTCONFIG_LIBRARY})

# unistd.h -- only for examles from FontConfig.
if(MSVC)
  set(unistd_INCLUDE_DIR "${lib_SRC_DIR}/src/msvc")
  target_include_directories(${PROJECT_NAME} PRIVATE ${unistd_INCLUDE_DIR})
endif()

# Dirent
if(MSVC)
  target_include_directories(${PROJECT_NAME} PRIVATE ${DIRENT_INCLUDE_DIR})
endif()

# Expat
target_include_directories(${PROJECT_NAME} PRIVATE ${EXPAT_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PRIVATE ${EXPAT_LIBRARY})

# FreeType
target_link_libraries(${PROJECT_NAME} PRIVATE Freetype::Freetype)

if(ANDROID AND ANDROID_NATIVE_API_LEVEL LESS 21)
  target_link_libraries(${PROJECT_NAME} PRIVATE android_support)
endif()


#-----------------------------------------------------------------------
# Testing
#-----------------------------------------------------------------------

set(test_src_DIR "${CMAKE_CURRENT_LIST_DIR}/src")
add_subdirectory(test)
