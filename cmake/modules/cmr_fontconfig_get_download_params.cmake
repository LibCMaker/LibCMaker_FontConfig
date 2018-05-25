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

include(cmr_get_version_parts)
include(cmr_print_fatal_error)

function(cmr_fontconfig_get_download_params
    version
    out_url out_sha out_src_dir_name out_tar_file_name)

  set(lib_base_url "https://www.freedesktop.org/software/fontconfig/release")

  if(version VERSION_EQUAL "2.11.95")
    set(lib_sha
      "7b165eee7aa22dcc1557db56f58d905b6a14b32f9701c79427452474375b4c89")
  endif()
#  if(version VERSION_EQUAL "2.12.91")
#    set(lib_sha
#      "4d56b2f88bc99a2e0e2532e1e047f60c7977a2f939d81e76aca0d146b9a6457e")
#  endif()
  if(version VERSION_EQUAL "2.13.0")
    set(lib_sha
      "91dde8492155b7f34bb95079e79be92f1df353fcc682c19be90762fd3e12eeb9")
  endif()

  if(NOT DEFINED lib_sha)
    cmr_print_fatal_error("Library version ${version} is not supported.")
  endif()

  cmr_get_version_parts(${version} major minor patch tweak)
  
  set(lib_src_name "fontconfig-${major}.${minor}.${patch}")
  set(lib_tar_file_name "${lib_src_name}.tar.bz2")
  set(lib_url "${lib_base_url}/${lib_tar_file_name}")

  set(${out_url} "${lib_url}" PARENT_SCOPE)
  set(${out_sha} "${lib_sha}" PARENT_SCOPE)
  set(${out_src_dir_name} "${lib_src_name}" PARENT_SCOPE)
  set(${out_tar_file_name} "${lib_tar_file_name}" PARENT_SCOPE)
endfunction()
