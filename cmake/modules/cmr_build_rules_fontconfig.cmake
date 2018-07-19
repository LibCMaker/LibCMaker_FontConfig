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

# Part of "LibCMaker/cmake/modules/cmr_build_rules.cmake".

  # Configure the used libs.
  if(MSVC)
    if(NOT LIBCMAKER_DIRENT_SRC_DIR)
      cmr_print_fatal_error(
        "Please set LIBCMAKER_DIRENT_SRC_DIR with path to LibCMaker_Dirent root.")
    endif()
    # To use our FindDirent.cmake in FontConfig's CMakeLists.txt
    list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_DIRENT_SRC_DIR}/cmake")
  endif()
  
  if(NOT LIBCMAKER_EXPAT_SRC_DIR)
    cmr_print_fatal_error(
      "Please set LIBCMAKER_EXPAT_SRC_DIR with path to LibCMaker_Expat root.")
  endif()
  # To use our FindEXPAT.cmake in FontConfig's CMakeLists.txt
  list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_EXPAT_SRC_DIR}/cmake")
  
  if(NOT LIBCMAKER_FREETYPE_SRC_DIR)
    cmr_print_fatal_error(
      "Please set LIBCMAKER_FREETYPE_SRC_DIR with path to LibCMaker_FreeType root.")
  endif()
  # To use our FindFreetype.cmake in FontConfig's CMakeLists.txt
  list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_FREETYPE_SRC_DIR}/cmake")


  # Copy CMake build scripts.
  if(COPY_FONTCONFIG_CMAKE_BUILD_SCRIPTS)
    cmr_print_message(
      "Copy CMake build scripts to unpacked sources.")
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${lib_BASE_DIR}/cmake/modules/fontconfig-${lib_VERSION}
        ${lib_SRC_DIR}/
    )
    if(MSVC)
      execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy
          ${lib_BASE_DIR}/cmake/modules/fontconfig-${lib_VERSION}/src/msvc/unistd.h
          ${lib_SRC_DIR}/src/
      )
    endif()
  endif()
  

  # Configure library.
  add_subdirectory(${lib_SRC_DIR} ${lib_VERSION_BUILD_DIR})
