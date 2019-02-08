# ****************************************************************************
#  Project:  LibCMaker_STLCache
#  Purpose:  A CMake build script for STLCache library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2019 NikitaFeodonit
#
#    This file is part of the LibCMaker_STLCache project.
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

# Testing with Google Test.
if(BUILD_TESTING)
  find_package(GTest REQUIRED)

  set(test_NAME "Examle_test")
  add_executable(${test_NAME} "")
  target_sources(${test_NAME}
    PRIVATE
      ${test_src_DIR}/example_test.cpp
  )
  set_target_properties(${test_NAME} PROPERTIES
    CXX_STANDARD 11
    C_STANDARD 11
  )

  # FontConfig
  target_include_directories(${test_NAME} PRIVATE ${FONTCONFIG_INCLUDE_DIR})
  target_link_libraries(${test_NAME} PRIVATE ${FONTCONFIG_LIBRARY})

  # unistd.h -- only for examles from FontConfig.
  if(MSVC)
    set(unistd_INCLUDE_DIR "${lib_SRC_DIR}/src/msvc")
    target_include_directories(${test_NAME} PRIVATE ${unistd_INCLUDE_DIR})
  endif()

  # Dirent
  if(MSVC)
    target_include_directories(${test_NAME} PRIVATE ${DIRENT_INCLUDE_DIR})
  endif()

  # Expat
  target_include_directories(${test_NAME} PRIVATE ${EXPAT_INCLUDE_DIR})
  target_link_libraries(${test_NAME} PRIVATE ${EXPAT_LIBRARY})

  # FreeType
  target_link_libraries(${test_NAME} PRIVATE Freetype::Freetype)

  if(ANDROID AND ANDROID_NATIVE_API_LEVEL LESS 21)
    target_link_libraries(${test_NAME} PRIVATE android_support)
  endif()

  target_link_libraries(${test_NAME} PRIVATE
    GTest::GTest GTest::Main
  )

  add_test(NAME ${test_NAME} COMMAND ${test_NAME})
endif()


# For running test, 1st build all:
#   cmake .. -DBUILD_TESTING=ON
#   cmake --build .
# Then run test with this command:
#   cmake -E env CTEST_OUTPUT_ON_FAILURE=1 cmake --build . --target test
# Or with this command:
#   ctest --verbose
# Env var CTEST_OUTPUT_ON_FAILURE or key --verbose are for show test outputs,
# see
# https://stackoverflow.com/a/37123943
# https://stackoverflow.com/a/38386596

# For Visual Studio:
# https://stackoverflow.com/a/31124523
# https://stackoverflow.com/a/37123943
# cmake -E env CTEST_OUTPUT_ON_FAILURE=1 cmake --build . --target RUN_TESTS
