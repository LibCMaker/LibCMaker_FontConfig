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

cmake_minimum_required(VERSION 3.3)

project(LibCMaker_FontConfig_Compile_Test C)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(cmr_PRINT_DEBUG ON)


#-----------------------------------------------------------------------
# Configure to find_package()
#-----------------------------------------------------------------------

# Set CMake's search path for find_*() commands.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(ANDROID)
  list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
endif()


#-----------------------------------------------------------------------
# Set path to LibCMaker root
#-----------------------------------------------------------------------

set(LibCMaker_DIR "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker")
# Uncomment it if need functions from LibCMaker
#list(APPEND CMAKE_MODULE_PATH "${LibCMaker_DIR}/cmake")
include(${LibCMaker_DIR}/cmake/cmr_find_package.cmake)


#-----------------------------------------------------------------------
# Set vars to LibCMaker_FontConfig
#-----------------------------------------------------------------------

set(FONTCONFIG_lib_NAME     "FontConfig")
set(FONTCONFIG_lib_VERSION  "2.13.0")
set(FONTCONFIG_lib_DIR  "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker_FontConfig")

# To use below for sample sources.
set(cmr_UNPACKED_DIR ${CMAKE_CURRENT_BINARY_DIR}/download/unpacked)

# To use our FindFontConfig.cmake.
list(APPEND CMAKE_MODULE_PATH "${FONTCONFIG_lib_DIR}/cmake/modules")

set(COPY_FONTCONFIG_CMAKE_BUILD_SCRIPTS ON)


#-----------------------------------------------------------------------
# Library specific vars and options
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# Build, install and find the Dirent
#-----------------------------------------------------------------------

if(MSVC)
  set(DIRENT_lib_NAME     "Dirent")
  set(DIRENT_lib_VERSION  "1.23.1")
  set(DIRENT_lib_DIR      "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker_Dirent")

  # To use our FindDirent.cmake.
  list(APPEND CMAKE_MODULE_PATH "${DIRENT_lib_DIR}/cmake/modules")

  set(COPY_DIRENT_CMAKE_BUILD_SCRIPTS ON)

  cmr_find_package(
    LibCMaker_DIR   ${LibCMaker_DIR}
    NAME            ${DIRENT_lib_NAME}
    VERSION         ${DIRENT_lib_VERSION}
    LIB_DIR         ${DIRENT_lib_DIR}
    REQUIRED
  )

  # Needed for cmr_find_package_fontconfig to build FontConfig with Dirent.
  set(LIBCMAKER_DIRENT_SRC_DIR "${DIRENT_lib_DIR}")
endif()


#-----------------------------------------------------------------------
# Build, install and find the Expat
#-----------------------------------------------------------------------

set(EXPAT_lib_NAME      "Expat")
set(EXPAT_lib_VERSION   "2.2.5")
set(EXPAT_lib_DIR       "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker_Expat")

# To use our FindEXPAT.cmake.
list(APPEND CMAKE_MODULE_PATH "${EXPAT_lib_DIR}/cmake/modules")

#set(SKIP_INSTALL_ALL ON)

# Library specific vars and options.
option(BUILD_tools "build the xmlwf tool for expat library" OFF)
option(BUILD_examples "build the examples for expat library" OFF)
option(BUILD_tests "build the tests for expat library" OFF)
# Option BUILD_shared is set in lib_cmaker_expat() by BUILD_SHARED_LIBS.
#option(BUILD_shared "build a shared expat library" ${BUILD_SHARED_LIBS})
option(BUILD_doc "build man page for xmlwf" OFF)
option(USE_libbsd "utilize libbsd (for arc4random_buf)" OFF)
# Option INSTALL is set in lib_cmaker_expat() by NOT SKIP_INSTALL_ALL.
# Set in 'cmr_build_rules_expat' as NOT SKIP_INSTALL_ALL.
#option(INSTALL "install expat files in cmake install target" ${NOT SKIP_INSTALL_ALL})

# Configuration options.
set(XML_CONTEXT_BYTES 1024 CACHE STRING
  "Define to specify how much context to retain around the current parse point")
option(XML_DTD
  "Define to make parameter entity parsing functionality available" ON)
option(XML_NS "Define to make XML Namespaces functionality available" ON)
if(NOT WIN32)
  option(XML_DEV_URANDOM
    "Define to include code reading entropy from `/dev/urandom'." ON)
endif()

cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${EXPAT_lib_NAME}
  VERSION         ${EXPAT_lib_VERSION}
  LIB_DIR         ${EXPAT_lib_DIR}
  REQUIRED
  FIND_MODULE_NAME EXPAT
)

# Needed for cmr_find_package_fontconfig to build FontConfig with Expat.
set(LIBCMAKER_EXPAT_SRC_DIR "${EXPAT_lib_DIR}")


#-----------------------------------------------------------------------
# Build, install and find the FreeType
#-----------------------------------------------------------------------

set(FT_lib_NAME     "FreeType")
set(FT_lib_VERSION  "2.9.1")
set(FT_lib_DIR      "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker_FreeType")

# To use our FindFreetype.cmake.
list(APPEND CMAKE_MODULE_PATH "${FT_lib_DIR}/cmake/modules")

set(COPY_FREETYPE_CMAKE_BUILD_SCRIPTS ON)

# Library specific vars and options.
set(FREETYPE_NO_DIST ON)

set(FT_WITH_ZLIB OFF)
set(FT_WITH_BZip2 OFF)
set(FT_WITH_PNG OFF)
set(FT_WITH_HarfBuzz OFF)

cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${FT_lib_NAME}
  VERSION         ${FT_lib_VERSION}
  LIB_DIR         ${FT_lib_DIR}
  REQUIRED
#  CONFIG
  NOT_USE_VERSION_IN_FIND_PACKAGE
  CUSTOM_LOGIC_FILE ${FT_lib_DIR}/cmake/cmr_find_package_freetype_custom.cmake
)

# Needed for cmr_find_package_fontconfig to build FontConfig with FreeType.
set(LIBCMAKER_FREETYPE_SRC_DIR "${FT_lib_DIR}")


#-----------------------------------------------------------------------
# Build, install and find the FontConfig
#-----------------------------------------------------------------------

# Make build and install the library at a config CMake phase.
#include(${LibCMaker_DIR}/cmake/cmr_find_package.cmake) # See above.
cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${FONTCONFIG_lib_NAME}
  VERSION         ${FONTCONFIG_lib_VERSION}
  LIB_DIR         ${FONTCONFIG_lib_DIR}
  REQUIRED
)


#-----------------------------------------------------------------------
# Link to the library
#-----------------------------------------------------------------------

# Build test executables.

# Get an example sources from the lib sources.
set(lib_SRC_DIR
  "${cmr_UNPACKED_DIR}/fontconfig-${FONTCONFIG_lib_VERSION}/fontconfig-${FONTCONFIG_lib_VERSION}"
)
set(lib_EXAMPLES_SRC_DIR ${lib_SRC_DIR})
if(MSVC)
  set(example_SRC fc-list.c)
else()
  set(example_SRC ${lib_EXAMPLES_SRC_DIR}/fc-list/fc-list.c)
endif()

add_executable(${PROJECT_NAME} ${example_SRC})

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
target_include_directories(${PROJECT_NAME} PRIVATE ${FREETYPE_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PRIVATE ${FREETYPE_LIBRARIES})

if(ANDROID)
  target_link_libraries(${PROJECT_NAME} PRIVATE android_support)
endif()
