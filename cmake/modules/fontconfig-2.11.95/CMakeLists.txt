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

# Based on the code from:
# https://github.com/CMakePorts/fontconfig
# https://github.com/codicodi/vcpkg/tree/master/ports/fontconfig

cmake_minimum_required(VERSION 3.2)

set(lib_NAME "fontconfig")
project(${lib_NAME})

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")

if(MSVC)
  find_package(Dirent REQUIRED)
endif()
find_package(EXPAT REQUIRED)
find_package(Freetype REQUIRED)


# Values without quotes.
set(fc_VERSION "2.11.95")
set(fc_FONTCONFIG_PATH "${CMAKE_INSTALL_PREFIX}/etc/fonts")
set(fc_CONFIGDIR "${fc_FONTCONFIG_PATH}/conf.d")
set(fc_CONFIGDIR_AVAIL "${fc_FONTCONFIG_PATH}/conf.avail")
set(fc_FC_ADD_FONTS "")
set(fc_FC_FONTPATH)

if(UNIX AND NOT APPLE)
  set(fc_FC_CACHEDIR "/var/cache/fontconfig")
  set(fc_FC_DEFAULT_FONTS "/usr/share/fonts")
endif()

if(WIN32)
  # May be "LOCAL_APPDATA_FONTCONFIG_CACHE", "WINDOWSTEMPDIR_FONTCONFIG_CACHE". 
  #From ChangeLog:  
  #Date:   Sun Nov 17 22:38:28 2013 +1300
  #Defaulting <cachedir> to LOCAL_APPDATA_FONTCONFIG_CACHE for Win32 build.
  #Date:   Tue Nov 13 16:41:55 2007 -0800
  #"WINDOWSTEMPDIR_FONTCONFIG_CACHE" it is replaced at runtime with a path
  #under the machine's (or user's) temp folder as returned by GetTempPath().
  set(fc_FC_CACHEDIR "LOCAL_APPDATA_FONTCONFIG_CACHE")
#  set(fc_FC_CACHEDIR "%TEMP%\\fc_cache")

  # May be "CUSTOMFONTDIR", "APPSHAREFONTDIR", "WINDOWSFONTDIR".
  # "APPSHAREFONTDIR" => to the '../share/fonts' relative to binary location.
  # "CUSTOMFONTDIR"   => to the 'fonts/' directory where the exe is located.
  # "WINDOWSFONTDIR"  => to the system's font directory.      
  set(fc_FC_DEFAULT_FONTS "WINDOWSFONTDIR")
#  set(fc_FC_DEFAULT_FONTS "%WINDIR%\\fonts")

  unset(fc_CONFIGDIR_AVAIL)

  if(NOT BUILD_SHARED_LIBS)
    set(fc_FONTCONFIG_FILE "${fc_FONTCONFIG_PATH}/fonts.conf")
    set(FONTCONFIG_FILE "\"${fc_FONTCONFIG_FILE}\"")
  endif()
endif()

# Values with quotes.
set(CONFIGDIR "\"${fc_CONFIGDIR}\"")
set(FC_ADD_FONTS "\"${fc_FC_ADD_FONTS}\"")
set(FC_CACHEDIR "\"${fc_FC_CACHEDIR}\"")
set(FC_DEFAULT_FONTS "\"${fc_FC_DEFAULT_FONTS}\"")
#set(FC_FONTPATH "\"${fc_FC_FONTPATH}\"")
set(FC_FONTPATH)
set(FONTCONFIG_PATH "\"${fc_FONTCONFIG_PATH}\"")

# Values from VCPKG
#if(WIN32)
#  set(FC_CACHEDIR WINDOWSTEMPDIR_FONTCONFIG_CACHE)
#  set(FC_DEFAULT_FONTS WINDOWSFONTDIR)
#  set(CONFIGDIR ./fonts/conf.d)
#  set(FC_FONTPATH)
#  set(FC_ADD_FONTS "\"yes\"")
#  set(LT_OBJDIR "\".libs/\"")
#endif()


include(ConfigureChecks.cmake)

set(fontconfig_SRCS
  ${PROJECT_SOURCE_DIR}/src/fcarch.c
  ${PROJECT_SOURCE_DIR}/src/fcatomic.c
  ${PROJECT_SOURCE_DIR}/src/fcblanks.c
  ${PROJECT_SOURCE_DIR}/src/fccache.c
  ${PROJECT_SOURCE_DIR}/src/fccfg.c
  ${PROJECT_SOURCE_DIR}/src/fccharset.c
  ${PROJECT_SOURCE_DIR}/src/fccompat.c
  ${PROJECT_SOURCE_DIR}/src/fcdbg.c
  ${PROJECT_SOURCE_DIR}/src/fcdefault.c
  ${PROJECT_SOURCE_DIR}/src/fcdir.c
  ${PROJECT_SOURCE_DIR}/src/fcformat.c
  ${PROJECT_SOURCE_DIR}/src/fcfreetype.c
  ${PROJECT_SOURCE_DIR}/src/fcfs.c
  ${PROJECT_SOURCE_DIR}/src/fcinit.c
  ${PROJECT_SOURCE_DIR}/src/fclang.c
  ${PROJECT_SOURCE_DIR}/src/fclist.c
  ${PROJECT_SOURCE_DIR}/src/fcmatch.c
  ${PROJECT_SOURCE_DIR}/src/fcmatrix.c
  ${PROJECT_SOURCE_DIR}/src/fcname.c
  ${PROJECT_SOURCE_DIR}/src/fcobjs.c
  ${PROJECT_SOURCE_DIR}/src/fcpat.c
  ${PROJECT_SOURCE_DIR}/src/fcrange.c
  ${PROJECT_SOURCE_DIR}/src/fcserialize.c
  ${PROJECT_SOURCE_DIR}/src/fcstat.c
  ${PROJECT_SOURCE_DIR}/src/fcstr.c
  ${PROJECT_SOURCE_DIR}/src/fcweight.c
  ${PROJECT_SOURCE_DIR}/src/fcxml.c
  ${PROJECT_SOURCE_DIR}/src/ftglue.c
)

add_library(${lib_NAME} ${fontconfig_SRCS})
set_property(TARGET ${lib_NAME} PROPERTY C_STANDARD 99)
#set_property(TARGET ${lib_NAME} PROPERTY OUTPUT_NAME fontconfig)
target_compile_definitions(${lib_NAME} PRIVATE
  -DHAVE_CONFIG_H
  -DFONTCONFIG_PATH=${FONTCONFIG_PATH}
  -DFC_CACHEDIR=${FC_CACHEDIR}
)

if(WIN32 AND NOT BUILD_SHARED_LIBS)
  # Set FONTCONFIG_FILE for static building as FONTCONFIG_PATH is not used.
  #target_compile_definitions(${lib_NAME} PRIVATE
  #  -DFONTCONFIG_FILE=${FONTCONFIG_FILE}
  #)
endif()

target_include_directories(${lib_NAME} PRIVATE ${PROJECT_SOURCE_DIR})
target_include_directories(${lib_NAME} PRIVATE ${PROJECT_SOURCE_DIR}/src)
target_include_directories(${lib_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

if(MSVC)
#  set_target_properties(${lib_NAME} PROPERTIES
#    DEFINE_SYMBOL "FcPublic=__declspec(dllexport)"
#  )

#  target_compile_definitions(${lib_NAME} PRIVATE
#    -D_CRT_SECURE_NO_DEPRECATE
#    -D_CRT_NONSTDC_NO_DEPRECATE
#    -wd4018
#    -DWINPOSIX_EXPORT=
#    -DPIC
#  )
endif()

# Dirent
if(MSVC)
  target_include_directories(${lib_NAME} PRIVATE ${DIRENT_INCLUDE_DIR})
endif()

# Expat
if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(${lib_NAME} PRIVATE
    -DXML_STATIC
  )
endif()
target_include_directories(${lib_NAME} PRIVATE ${EXPAT_INCLUDE_DIR})
target_link_libraries(${lib_NAME} PUBLIC ${EXPAT_LIBRARY})

# FreeType
target_include_directories(${lib_NAME} PRIVATE ${FREETYPE_INCLUDE_DIRS})
target_link_libraries(${lib_NAME} PUBLIC ${FREETYPE_LIBRARIES})

install(TARGETS ${lib_NAME}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT SKIP_INSTALL_HEADERS)
  install(
    FILES
      ${PROJECT_SOURCE_DIR}/fontconfig/fcfreetype.h
      ${PROJECT_SOURCE_DIR}/fontconfig/fcprivate.h
      ${PROJECT_SOURCE_DIR}/fontconfig/fontconfig.h
    DESTINATION include/fontconfig
  )
endif()

if(NOT SKIP_INSTALL_TOOLS)
  # Remove quotes for fonts.conf.in.
  set(FC_CACHEDIR ${fc_FC_CACHEDIR})
  set(FC_DEFAULT_FONTS ${fc_FC_DEFAULT_FONTS})

  configure_file(
    ${PROJECT_SOURCE_DIR}/fonts.conf.in
    ${CMAKE_CURRENT_BINARY_DIR}/fonts.conf @ONLY
  )

  install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/fonts.conf
    DESTINATION ${fc_FONTCONFIG_PATH}
  )
  install(
    DIRECTORY ${PROJECT_SOURCE_DIR}/conf.d/
    DESTINATION ${fc_CONFIGDIR}
    FILES_MATCHING PATTERN "*.conf"
  )

  if(fc_CONFIGDIR_AVAIL)
    install(
      DIRECTORY ${PROJECT_SOURCE_DIR}/conf.d/
      DESTINATION ${fc_CONFIGDIR_AVAIL}
      FILES_MATCHING PATTERN "*.conf"
    )
  endif()
endif()
