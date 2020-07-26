# ****************************************************************************
#  Project:  LibCMaker_FontConfig
#  Purpose:  A CMake build script for FontConfig library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2019 NikitaFeodonit
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

#-----------------------------------------------------------------------
# The file is an example of the convenient script for the library build.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Lib's name, version, paths
#-----------------------------------------------------------------------

set(FONTCONFIG_lib_NAME "FontConfig")
set(FONTCONFIG_lib_VERSION "2.13.0" CACHE STRING "FONTCONFIG_lib_VERSION")
set(
  FONTCONFIG_lib_DIR "${CMAKE_CURRENT_LIST_DIR}"
  CACHE PATH "FONTCONFIG_lib_DIR"
)

# To use our Find<LibName>.cmake.
list(APPEND CMAKE_MODULE_PATH "${FONTCONFIG_lib_DIR}/cmake/modules")


#-----------------------------------------------------------------------
# LibCMaker_<LibName> specific vars and options
#-----------------------------------------------------------------------

option(
  COPY_FONTCONFIG_CMAKE_BUILD_SCRIPTS "COPY_FONTCONFIG_CMAKE_BUILD_SCRIPTS" ON
)

# Used in 'cmr_build_rules_fontconfig.cmake'.
if(MSVC)
  set(
    LIBCMAKER_DIRENT_SRC_DIR "${LibCMaker_LIB_DIR}/LibCMaker_Dirent"
    CACHE PATH "LIBCMAKER_DIRENT_SRC_DIR"
  )
endif()
set(
  LIBCMAKER_EXPAT_SRC_DIR "${LibCMaker_LIB_DIR}/LibCMaker_Expat"
  CACHE PATH "LIBCMAKER_EXPAT_SRC_DIR"
)
set(
  LIBCMAKER_FREETYPE_SRC_DIR "${LibCMaker_LIB_DIR}/LibCMaker_FreeType"
  CACHE PATH "LIBCMAKER_FREETYPE_SRC_DIR"
)


#-----------------------------------------------------------------------
# Library specific vars and options
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# Build, install and find the library
#-----------------------------------------------------------------------

cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${FONTCONFIG_lib_NAME}
  VERSION         ${FONTCONFIG_lib_VERSION}
  LIB_DIR         ${FONTCONFIG_lib_DIR}
  REQUIRED
  FIND_MODULE_NAME Fontconfig
)
