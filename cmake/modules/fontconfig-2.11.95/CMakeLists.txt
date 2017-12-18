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

# Based on https://github.com/CMakePorts/fontconfig

cmake_minimum_required(VERSION 3.2)

set(lib_NAME "fontconfig")
project(${lib_NAME})

#list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")

find_package(EXPAT REQUIRED)
find_package(Freetype REQUIRED)

include(ConfigureChecks.cmake)

add_subdirectory(conf.d)
add_subdirectory(fontconfig)

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

if(MSVC)
  list(APPEND fontconfig_SRCS
    dirent.c
    mmap.c
    unistd.c
  )
endif()

add_library(${lib_NAME} ${fontconfig_SRCS})
set_property(TARGET ${lib_NAME} PROPERTY C_STANDARD 99)
set_property(TARGET ${lib_NAME} PROPERTY OUTPUT_NAME fontconfig)
target_compile_definitions(${lib_NAME} PRIVATE
  -DHAVE_CONFIG_H
  -DFONTCONFIG_PATH="\\"${CMAKE_INSTALL_PREFIX}/etc/fonts\\""
)
target_include_directories(${lib_NAME} PRIVATE ${PROJECT_SOURCE_DIR})
target_include_directories(${lib_NAME} PRIVATE ${PROJECT_SOURCE_DIR}/src)
target_include_directories(${lib_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

if(MSVC)
  target_include_directories(${lib_NAME} PRIVATE ${PROJECT_SOURCE_DIR}/msvc)
  target_compile_definitions(${lib_NAME} PRIVATE
    -D_CRT_SECURE_NO_DEPRECATE
    -D_CRT_NONSTDC_NO_DEPRECATE
    -wd4018
    -DWINPOSIX_EXPORT=
    -DPIC
  )
endif()

# Expat
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
