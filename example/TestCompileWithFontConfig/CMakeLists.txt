# ****************************************************************************
#  Project:  LibCMaker_FontConfig
#  Purpose:  A CMake build script for FontConfig library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017 NikitaFeodonit
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

cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project(LibCMaker_FontConfig_Compile_Test C)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")


#-----------------------------------------------------------------------
# Configure for find_package.
#-----------------------------------------------------------------------

# Set CMake's search path for find_package(), find_program(), find_library(),
# find_file(), and find_path() commands.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(ANDROID)
  list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
endif()


#-----------------------------------------------------------------------
# Set path to LibCMaker root
#-----------------------------------------------------------------------

set(LIBCMAKER_SRC_DIR "${PROJECT_SOURCE_DIR}/cmake/LibCMaker")
# Uncomment it if need functions from LibCMaker
#list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")


#-----------------------------------------------------------------------
# Set vars for LibCMaker_FontConfig.
#-----------------------------------------------------------------------

# Standard CMake vars.
#set(BUILD_SHARED_LIBS ON)

#set(SKIP_INSTALL_HEADERS ON)
#set(SKIP_INSTALL_LIBRARIES ON)
#set(SKIP_INSTALL_ALL ON)

# Set useful vars for lib_cmaker_fontconfig().
set(cmr_PRINT_DEBUG ON)

#set(lib_VERSION "2.11.1.1")
set(lib_VERSION "2.11.95")
#set(lib_VERSION "2.12.91")

set(DOWNLOAD_DIR "${PROJECT_BINARY_DIR}")
set(UNPACKED_SRC_DIR "${PROJECT_BINARY_DIR}")
set(BUILD_DIR "${PROJECT_BINARY_DIR}/build_fontconfig")

set(COPY_FONTCONFIG_CMAKE_BUILD_SCRIPTS ON)

# Library specific vars and options.
set(FONTCONFIG_DIR "${CMAKE_INSTALL_PREFIX}")
set(ENV{FONTCONFIG_DIR} "${FONTCONFIG_DIR}")


#-----------------------------------------------------------------------
# Build and install the Expat.
#-----------------------------------------------------------------------

set(EXPAT_lib_VERSION "2.2.5")

set(EXPAT_DOWNLOAD_DIR "${PROJECT_BINARY_DIR}")
set(EXPAT_UNPACKED_SRC_DIR "${PROJECT_BINARY_DIR}")
set(EXPAT_BUILD_DIR "${PROJECT_BINARY_DIR}/build_expat")

# Library specific vars and options.
set(EXPAT_DIR "${CMAKE_INSTALL_PREFIX}")
set(ENV{EXPAT_DIR} "${EXPAT_DIR}")

option(BUILD_tools "build the xmlwf tool for expat library" OFF)
option(BUILD_examples "build the examples for expat library" OFF)
option(BUILD_tests "build the tests for expat library" OFF)
# Option BUILD_shared is set in lib_cmaker_expat() by BUILD_SHARED_LIBS.
#option(BUILD_shared "build a shared expat library" ${BUILD_SHARED_LIBS})
option(BUILD_doc "build man page for xmlwf" OFF)
option(USE_libbsd "utilize libbsd (for arc4random_buf)" OFF)
# Option INSTALL is set in lib_cmaker_expat() by NOT SKIP_INSTALL_ALL.
#option(INSTALL "install expat files in cmake install target" ON)

# configuration options
set(XML_CONTEXT_BYTES 1024 CACHE STRING
  "Define to specify how much context to retain around the current parse point")
option(XML_DTD
  "Define to make parameter entity parsing functionality available" ON)
option(XML_NS "Define to make XML Namespaces functionality available" ON)
if(NOT WIN32)
  option(XML_DEV_URANDOM
    "Define to include code reading entropy from `/dev/urandom'." ON)
endif()

include(
  ${PROJECT_SOURCE_DIR}/cmake/LibCMaker_Expat/lib_cmaker_expat.cmake)
lib_cmaker_expat(
  VERSION ${EXPAT_lib_VERSION}
  DOWNLOAD_DIR ${EXPAT_DOWNLOAD_DIR}
  UNPACKED_SRC_DIR ${EXPAT_UNPACKED_SRC_DIR}
  BUILD_DIR ${EXPAT_BUILD_DIR}
)

# Needed for lib_cmaker_fontconfig() to build FontConfig with Expat
set(LIBCMAKER_EXPAT_SRC_DIR
  "${PROJECT_SOURCE_DIR}/cmake/LibCMaker_Expat")
# To use our FindEXPAT.cmake
list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_EXPAT_SRC_DIR}/cmake")

find_package(EXPAT REQUIRED)


#-----------------------------------------------------------------------
# Build and install the FreeType.
#-----------------------------------------------------------------------

set(FREETYPE_DIR "${CMAKE_INSTALL_PREFIX}")
set(ENV{FREETYPE_DIR} "${FREETYPE_DIR}")

set(FT_lib_VERSION "2.8.1")

set(FT_DOWNLOAD_DIR "${PROJECT_BINARY_DIR}")
set(FT_UNPACKED_SRC_DIR "${PROJECT_BINARY_DIR}")
set(FT_BUILD_DIR "${PROJECT_BINARY_DIR}/build_freetype")

# Library specific vars.
set(FREETYPE_NO_DIST ON)

set(WITH_ZLIB OFF)
set(WITH_BZip2 OFF)
set(WITH_PNG OFF)
set(WITH_HarfBuzz OFF)

include(
  ${PROJECT_SOURCE_DIR}/cmake/LibCMaker_FreeType/lib_cmaker_freetype.cmake)
lib_cmaker_freetype(
  VERSION ${FT_lib_VERSION}
  DOWNLOAD_DIR ${FT_DOWNLOAD_DIR}
  UNPACKED_SRC_DIR ${FT_UNPACKED_SRC_DIR}
  BUILD_DIR ${FT_BUILD_DIR}
)

# Needed for lib_cmaker_fontconfig() to build FontConfig with FreeType
set(LIBCMAKER_FREETYPE_SRC_DIR
  "${PROJECT_SOURCE_DIR}/cmake/LibCMaker_FreeType")
# To use our FindFreetype.cmake
list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_FREETYPE_SRC_DIR}/cmake")

find_package(Freetype REQUIRED)


#-----------------------------------------------------------------------
# Build and install the FontConfig.
#-----------------------------------------------------------------------

include(
  ${PROJECT_SOURCE_DIR}/cmake/LibCMaker_FontConfig/lib_cmaker_fontconfig.cmake)

# Make compile, build and install the library at a config CMake phase,
# generate the CMake config files.

# Install specified library version.
lib_cmaker_fontconfig(
  VERSION ${lib_VERSION}
  DOWNLOAD_DIR ${DOWNLOAD_DIR}
  UNPACKED_SRC_DIR ${UNPACKED_SRC_DIR}
  BUILD_DIR ${BUILD_DIR}
)


#-----------------------------------------------------------------------
# find_package
#-----------------------------------------------------------------------

set(LIBCMAKER_FONTCONFIG_SRC_DIR
  "${PROJECT_SOURCE_DIR}/cmake/LibCMaker_FontConfig")
# To use our FindFontConfig.cmake
list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_FONTCONFIG_SRC_DIR}/cmake")

# Use newly got library.
find_package(FontConfig REQUIRED)


#-----------------------------------------------------------------------
# Link to the library.
#-----------------------------------------------------------------------

# Get an example sources from the FontConfig sources.
include(
  ${PROJECT_SOURCE_DIR}/cmake/LibCMaker_FontConfig/cmake/modules/cmr_fontconfig_get_download_params.cmake)
cmr_fontconfig_get_download_params(${lib_VERSION}
  lib_URL lib_SHA lib_SRC_DIR_NAME lib_ARCH_FILE_NAME)
set(lib_SRC_DIR "${UNPACKED_SRC_DIR}/${lib_SRC_DIR_NAME}")

# Build test executables
add_executable(${PROJECT_NAME}
  ${lib_SRC_DIR}/fc-query/fc-query.c
)

# FontConfig
target_include_directories(${PROJECT_NAME} PRIVATE ${FONTCONFIG_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PRIVATE ${FONTCONFIG_LIBRARY})

# Expat
target_include_directories(${PROJECT_NAME} PRIVATE ${EXPAT_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PRIVATE ${EXPAT_LIBRARY})

# FreeType
target_include_directories(${PROJECT_NAME} PRIVATE ${FREETYPE_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PRIVATE ${FREETYPE_LIBRARIES})

if(ANDROID)
  target_link_libraries(${PROJECT_NAME} PRIVATE android_support)
endif()
