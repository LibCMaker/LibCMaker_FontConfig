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

# Part of "LibCMaker/cmake/cmr_find_package.cmake".

  if(MSVC)
    if(NOT LIBCMAKER_DIRENT_SRC_DIR)
      cmr_print_error(
        "Please set LIBCMAKER_DIRENT_SRC_DIR with path to LibCMaker_Dirent root.")
    endif()
    cmr_print_value(LIBCMAKER_DIRENT_SRC_DIR)
  endif()

  if(NOT LIBCMAKER_EXPAT_SRC_DIR)
    cmr_print_error(
      "Please set LIBCMAKER_EXPAT_SRC_DIR with path to LibCMaker_Expat root.")
  endif()
  cmr_print_value(LIBCMAKER_EXPAT_SRC_DIR)

  if(NOT LIBCMAKER_FREETYPE_SRC_DIR)
    cmr_print_error(
      "Please set LIBCMAKER_FREETYPE_SRC_DIR with path to LibCMaker_FreeType root.")
  endif()
  cmr_print_value(LIBCMAKER_FREETYPE_SRC_DIR)


  #-----------------------------------------------------------------------
  # Library specific build arguments.
  #-----------------------------------------------------------------------

## +++ Common part of the lib_cmaker_<lib_name> function +++
  set(find_LIB_VARS
    COPY_FONTCONFIG_CMAKE_BUILD_SCRIPTS

    LIBCMAKER_DIRENT_SRC_DIR
    LIBCMAKER_EXPAT_SRC_DIR
    LIBCMAKER_FREETYPE_SRC_DIR
  )

  foreach(d ${find_LIB_VARS})
    if(DEFINED ${d})
      list(APPEND find_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()
## --- Common part of the lib_cmaker_<lib_name> function ---


  #-----------------------------------------------------------------------
  # Building
  #-----------------------------------------------------------------------

## +++ Common part of the lib_cmaker_<lib_name> function +++
  cmr_lib_cmaker_main(
    LibCMaker_DIR ${find_LibCMaker_DIR}
    NAME          ${find_NAME}
    VERSION       ${find_VERSION}
    LANGUAGES     CXX C
    BASE_DIR      ${find_LIB_DIR}
    DOWNLOAD_DIR  ${cmr_DOWNLOAD_DIR}
    UNPACKED_DIR  ${cmr_UNPACKED_DIR}
    BUILD_DIR     ${lib_BUILD_DIR}
    CMAKE_ARGS    ${find_CMAKE_ARGS}
    INSTALL
  )
## --- Common part of the lib_cmaker_<lib_name> function ---
