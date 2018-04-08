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

if(NOT LIBCMAKER_SRC_DIR)
  message(FATAL_ERROR
    "Please set LIBCMAKER_SRC_DIR with path to LibCMaker root")
endif()
# TODO: prevent multiply includes for CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")


include(CMakeParseArguments) # cmake_parse_arguments

include(cmr_lib_cmaker)
include(cmr_print_debug_message)
include(cmr_print_message)
include(cmr_print_var_value)


if(MSVC)
  if(NOT LIBCMAKER_DIRENT_SRC_DIR)
    cmr_print_fatal_error(
      "Please set LIBCMAKER_DIRENT_SRC_DIR with path to LibCMaker_Dirent root.")
  endif()
endif()

if(NOT LIBCMAKER_EXPAT_SRC_DIR)
  cmr_print_fatal_error(
    "Please set LIBCMAKER_EXPAT_SRC_DIR with path to LibCMaker_Expat root.")
endif()

if(NOT LIBCMAKER_FREETYPE_SRC_DIR)
  cmr_print_fatal_error(
    "Please set LIBCMAKER_FREETYPE_SRC_DIR with path to LibCMaker_FreeType root.")
endif()

# To find library CMaker source dir.
set(lcm_LibCMaker_FONTCONFIG_SRC_DIR ${CMAKE_CURRENT_LIST_DIR})
# TODO: prevent multiply includes for CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${lcm_LibCMaker_FONTCONFIG_SRC_DIR}/cmake/modules")


function(lib_cmaker_fontconfig)
  cmake_minimum_required(VERSION 3.2)

  cmr_print_message("======== Build library: FontConfig ========")

  set(options
    # optional args
  )
  
  set(oneValueArgs
    # required args
    VERSION BUILD_DIR
    # optional args
    DOWNLOAD_DIR UNPACKED_SRC_DIR
  )

  set(multiValueArgs
    # optional args
  )

  cmake_parse_arguments(arg
      "${options}" "${oneValueArgs}" "${multiValueArgs}" "${ARGN}")
  # -> lib_VERSION
  # -> lib_BUILD_DIR
  # -> lib_* ...

  cmr_print_var_value(LIBCMAKER_SRC_DIR)
  if(MSVC)
    cmr_print_var_value(LIBCMAKER_DIRENT_SRC_DIR)
  endif()
  cmr_print_var_value(LIBCMAKER_EXPAT_SRC_DIR)
  cmr_print_var_value(LIBCMAKER_FREETYPE_SRC_DIR)

  cmr_print_var_value(arg_VERSION)
  cmr_print_var_value(arg_BUILD_DIR)

  cmr_print_var_value(arg_DOWNLOAD_DIR)
  cmr_print_var_value(arg_UNPACKED_SRC_DIR)

  # Required args
  if(NOT arg_VERSION)
    cmr_print_fatal_error("Argument VERSION is not defined.")
  endif()
  if(NOT arg_BUILD_DIR)
    cmr_print_fatal_error("Argument BUILD_DIR is not defined.")
  endif()
  if(arg_UNPARSED_ARGUMENTS)
    cmr_print_fatal_error(
      "There are unparsed arguments: ${arg_UNPARSED_ARGUMENTS}")
  endif()


  #-----------------------------------------------------------------------
  # Library specific build arguments.
  #-----------------------------------------------------------------------

  set(lcm_CMAKE_ARGS)

  set(LIB_VARS
    LIBCMAKER_DIRENT_SRC_DIR
    LIBCMAKER_EXPAT_SRC_DIR
    LIBCMAKER_FREETYPE_SRC_DIR
    
    COPY_FONTCONFIG_CMAKE_BUILD_SCRIPTS
  )

  foreach(d ${LIB_VARS})
    if(DEFINED ${d})
      list(APPEND lcm_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()

  
  #-----------------------------------------------------------------------
  # BUILDING
  #-----------------------------------------------------------------------

  cmr_lib_cmaker(
    VERSION ${arg_VERSION}
    PROJECT_DIR ${lcm_LibCMaker_FONTCONFIG_SRC_DIR}
    DOWNLOAD_DIR ${arg_DOWNLOAD_DIR}
    UNPACKED_SRC_DIR ${arg_UNPACKED_SRC_DIR}
    BUILD_DIR ${arg_BUILD_DIR}
    CMAKE_ARGS ${lcm_CMAKE_ARGS}
    INSTALL
  )

endfunction()
