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
  if(NOT MINGW AND NOT ANDROID AND NOT IOS
      AND NOT (APPLE AND CMAKE_GENERATOR MATCHES "Unix Makefiles"))
    set_target_properties(${test_NAME} PROPERTIES
      # Link all libraries into the target so as not to use LD_LIBRARY_PATH.
      LINK_WHAT_YOU_USE ON
    )
  endif()

  # FontConfig
  target_link_libraries(${test_NAME} PRIVATE Fontconfig::Fontconfig)

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

  if(NOT ANDROID AND NOT IOS)  # Linux, Windows, macOS
    add_test(NAME ${test_NAME} COMMAND ${test_NAME})
  endif()

  if(ANDROID)
    find_program(adb_exec adb)
    if(NOT adb_exec)
      message(FATAL_ERROR "Could not find 'adb'")
    endif()

    set(TEST_WORK_DIR "/data/local/tmp/LibCMaker_test")

    add_test(NAME rm_work_dir
      COMMAND ${adb_exec} shell "if [ -d \"${TEST_WORK_DIR}\" ] ; then rm -r \"${TEST_WORK_DIR}\" ; fi"
    )

    if(BUILD_SHARED_LIBS)
      add_test(NAME push_libs
        COMMAND ${adb_exec} push "${cmr_INSTALL_DIR}/lib" "${TEST_WORK_DIR}/lib"
      )

      find_library(cpp_shared_LIB "c++_shared")
      if(NOT cpp_shared_LIB)
        message(FATAL_ERROR "The library 'c++_shared' can not be found.")
      endif()

      get_filename_component(cpp_shared_LIB_FILE_NAME ${cpp_shared_LIB} NAME)

      add_test(NAME push_cpp_shared
        COMMAND ${adb_exec} push
          "${cpp_shared_LIB}"
          "${TEST_WORK_DIR}/lib/${cpp_shared_LIB_FILE_NAME}"
      )
    endif()

    add_test(NAME push_${test_NAME}
      COMMAND ${adb_exec} push ${test_NAME} "${TEST_WORK_DIR}/${test_NAME}"
    )
    add_test(NAME chmod_${test_NAME}
      COMMAND ${adb_exec} shell chmod 775 "${TEST_WORK_DIR}/${test_NAME}"
    )
    add_test(NAME cd_to_work_dir COMMAND ${adb_exec} shell
      cd "${TEST_WORK_DIR}"
    )
    add_test(NAME ${test_NAME} COMMAND ${adb_exec} shell
      "cd ${TEST_WORK_DIR} && "
      "LD_LIBRARY_PATH=${TEST_WORK_DIR}/lib ${TEST_WORK_DIR}/${test_NAME}"
      # :${LD_LIBRARY_PATH} || :/vendor/lib64:/system/lib64
    )
    set_tests_properties(${test_NAME} PROPERTIES
      PASS_REGULAR_EXPRESSION "PASSED"
    )
    set_tests_properties(${test_NAME} PROPERTIES
      FAIL_REGULAR_EXPRESSION "FAILED"
    )
  endif()
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
