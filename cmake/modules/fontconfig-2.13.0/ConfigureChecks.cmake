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

# Based on https://github.com/CMakePorts/fontconfig

# TODO: take options from 'configure.ac' and other original files.

# Checking Headers and Functions for fontconfig

include(CheckIncludeFile)
include(CheckIncludeFiles)
# TODO: replace check_function_exists() with check_symbol_exists()
include(CheckFunctionExists)
include(CheckStructHasMember)
include(CheckSymbolExists)
include(CheckTypeSize)

include(CheckFileOffsetBits)
include(CMakeTestInline) # Set C_INLINE_KEYWORD
include(TestLargeFiles)


# Dirent
list(APPEND CMAKE_REQUIRED_INCLUDES
  ${DIRENT_INCLUDE_DIR}
)

# Expat
list(APPEND CMAKE_REQUIRED_INCLUDES
  ${EXPAT_INCLUDE_DIR}
)
list(APPEND CMAKE_REQUIRED_LIBRARIES
  ${EXPAT_LIBRARIES}
)

# FreeType
list(APPEND CMAKE_REQUIRED_INCLUDES
  ${FREETYPE_INCLUDE_DIR}
)
list(APPEND CMAKE_REQUIRED_LIBRARIES
  ${FREETYPE_LIBRARIES}
)

# TODO: this is hack, the quotes must remain.
string(REPLACE "\"" "" cxx_std_libs "${CMAKE_CXX_STANDARD_LIBRARIES}")  # Documented in CMake 3.6
list(APPEND CMAKE_REQUIRED_LIBRARIES
  ${cxx_std_libs}
)

function(check_type_exists type variable header default)
  # Code from:
  # https://github.com/sumoprojects/sumokoin/blob/master/external/unbound/configure_checks.cmake
  set(CMAKE_EXTRA_INCLUDE_FILES "${header}")
  check_type_size("${type}" "${variable}")

  if(NOT HAVE_${type})
    set("${variable}" "${default}" PARENT_SCOPE)
  else()
    set("${variable}" "FALSE" PARENT_SCOPE)
  endif()
endfunction()


macro(check_freetype_struct_has_member struct member out_var)
  file(WRITE "${PROJECT_BINARY_DIR}/try_compile_${struct}_${member}.c"
  "
      #include <ft2build.h>
      #include FT_FREETYPE_H
      #include FT_TRUETYPE_TABLES_H

      int main()
      {
         (void)sizeof(((${struct} *)0)->${member});
         return 0;
      }
  ")
  try_compile(_${out_var}
    ${PROJECT_BINARY_DIR}/try_compile_${struct}_${member}
    SOURCES ${PROJECT_BINARY_DIR}/try_compile_${struct}_${member}.c
    CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${FREETYPE_INCLUDE_DIRS}"
#    LINK_LIBRARIES ${cxx_std_libs}
    OUTPUT_VARIABLE build_OUT
  )
  if(_${out_var})
    set(${out_var} 1)
    # set(${out_var} 1 PARENT_SCOPE) # PARENT_SCOPE needed for function.
    message(STATUS "Looking for ${out_var} - found")
  else()
    message(STATUS "Looking for ${out_var} - not found")
    message(STATUS ${build_OUT})
  endif()
endmacro()


macro(check_freetype_symbol_exists name out_var)
  file(WRITE "${PROJECT_BINARY_DIR}/try_compile_${name}.c"
  "
      #include <ft2build.h>
      #include FT_FREETYPE_H
      #include FT_BDF_H
      #include FT_TYPE1_TABLES_H
      #include FT_FONT_FORMATS_H

      int main(int argc, char** argv)
      {
        (void)argv;
      #ifndef ${name}
        return ((int*)(&${name}))[argc];
      #else
        (void)argc;
        return 0;
      #endif
      }
  ")

  try_compile(_${out_var}
    ${PROJECT_BINARY_DIR}/try_compile_${name}
    SOURCES ${PROJECT_BINARY_DIR}/try_compile_${name}.c
    CMAKE_FLAGS
      "-DINCLUDE_DIRECTORIES=${FREETYPE_INCLUDE_DIRS}"
#      "-DLINK_DIRECTORIES=${CMAKE_INSTALL_PREFIX}/lib"
    LINK_LIBRARIES ${FREETYPE_LIBRARIES} ${cxx_std_libs}
    OUTPUT_VARIABLE build_OUT
  )

  if(_${out_var})
    set(${out_var} 1)
    # set(${out_var} 1 PARENT_SCOPE) # PARENT_SCOPE needed for function.
    message(STATUS "Looking for ${out_var} - found")
  else()
    message(STATUS "Looking for ${out_var} - not found")
    message(STATUS ${build_OUT})
  endif()
endmacro()


macro(try_compile_intel_atomic_primitives out_var)
  # Code from:
  # https://github.com/harfbuzz/harfbuzz/blob/master/CMakeLists.txt

  ## Atomic ops availability detection
  file(WRITE "${PROJECT_BINARY_DIR}/try_compile_intel_atomic_primitives.c"
  "   
      void memory_barrier (void) { __sync_synchronize (); }
      int atomic_add (int *i) { return __sync_fetch_and_add (i, 1); }
      int mutex_trylock (int *m) { return __sync_lock_test_and_set (m, 1); }
      void mutex_unlock (int *m) { __sync_lock_release (m); }
      int main () { return 0; }
  ")
  try_compile(_${out_var}
    ${PROJECT_BINARY_DIR}/try_compile_intel_atomic_primitives
    SOURCES ${PROJECT_BINARY_DIR}/try_compile_intel_atomic_primitives.c
#    LINK_LIBRARIES ${cxx_std_libs}
    OUTPUT_VARIABLE build_OUT
  )
  if(_${out_var})
    set(${out_var} 1)
    # set(${out_var} 1 PARENT_SCOPE) # PARENT_SCOPE needed for function.
    message(STATUS "Looking for ${out_var} - found")
  else()
    message(STATUS "Looking for ${out_var} - not found")
    message(STATUS ${build_OUT})
  endif()
endmacro()


macro(try_compile_solaris_atomic_ops out_var)
  # Code from:
  # https://github.com/tamaskenez/harfbuzz-cmake/blob/master/CMakeLists.txt

  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/try_compile_solaris_atomic_ops.c"
  "
      #include <atomic.h>
      /* This requires Solaris Studio 12.2 or newer: */
      #include <mbarrier.h>
      void memory_barrier (void) { __machine_rw_barrier (); }
      int atomic_add (volatile unsigned *i) { return atomic_add_int_nv (i, 1); }
      void *atomic_ptr_cmpxchg (volatile void **target, void *cmp, void *newval)
        { return atomic_cas_ptr (target, cmp, newval); }
  ")
  try_compile(_${out_var}
    ${CMAKE_CURRENT_BINARY_DIR}/try_compile_solaris_atomic_ops
    SOURCES ${CMAKE_CURRENT_BINARY_DIR}/try_compile_solaris_atomic_ops.c
#    LINK_LIBRARIES ${cxx_std_libs}
    OUTPUT_VARIABLE build_OUT
  )
  if(_${out_var})
    set(${out_var} 1)
    # set(${out_var} 1 PARENT_SCOPE) # PARENT_SCOPE needed for function.
    message(STATUS "Looking for ${out_var} - found")
  else()
    message(STATUS "Looking for ${out_var} - not found")
    message(STATUS ${build_OUT})
  endif()
endmacro()

# TODO: add checks for '#cmakedefine' vars.

#/* Define if building universal (internal helper macro) */
#cmakedefine AC_APPLE_UNIVERSAL_BUILD @AC_APPLE_UNIVERSAL_BUILD@

# TODO: fix this alignof tests
check_type_size("double" ALIGNOF_DOUBLE)
check_type_size("void *" ALIGNOF_VOID_P)

if(ANDROID AND ANDROID_SYSROOT_ABI STREQUAL "x86")
  set(ALIGNOF_DOUBLE 4)
endif()

#/* Use libxml2 instead of Expat */
#cmakedefine ENABLE_LIBXML2 @ENABLE_LIBXML2@

#/* Define to 1 if translation of program messages to the user's native
#   language is requested. */
#cmakedefine ENABLE_NLS @ENABLE_NLS@

#/* Additional font directories */
# FC_ADD_FONTS is set in root CMakeLists.txt.

#/* Architecture prefix to use for cache file names */
#cmakedefine FC_ARCHITECTURE @FC_ARCHITECTURE@

#/* System font directory */
# FC_DEFAULT_FONTS is set in root CMakeLists.txt.

#/* The type of len parameter of the gperf hash/lookup function */
set(FC_GPERF_SIZE_T "unsigned int")

#/* Define to nothing if C supports flexible array members, and to 1 if it does
#   not. That way, with a declaration like `struct s { int n; double
#   d[FLEXIBLE_ARRAY_MEMBER]; };', the struct hack can be used with pre-C99
#   compilers. When computing the size of such an object, don't use 'sizeof
#   (struct s)' as it overestimates the size. Use 'offsetof (struct s, d)'
#   instead. Don't use 'offsetof (struct s, d[0])', as this doesn't work with
#   MSVC and with C++ compilers. */
#define FLEXIBLE_ARRAY_MEMBER

#/* Gettext package */
#cmakedefine GETTEXT_PACKAGE @GETTEXT_PACKAGE@

#/* Define to 1 if you have the Mac OS X function CFLocaleCopyCurrent in the
#   CoreFoundation framework. */
#cmakedefine HAVE_CFLOCALECOPYCURRENT @HAVE_CFLOCALECOPYCURRENT@

#/* Define to 1 if you have the Mac OS X function CFPreferencesCopyAppValue in
#   the CoreFoundation framework. */
#cmakedefine HAVE_CFPREFERENCESCOPYAPPVALUE @HAVE_CFPREFERENCESCOPYAPPVALUE@

#/* Define if the GNU dcgettext() function is already present or preinstalled.
#   */
#cmakedefine HAVE_DCGETTEXT @HAVE_DCGETTEXT@

check_include_file("dirent.h" HAVE_DIRENT_H)

check_include_file("dlfcn.h" HAVE_DLFCN_H)

# TODO: replace check_function_exists() with check_symbol_exists()
# TODO: What is header file for _doprnt to check_symbol_exists()?
check_function_exists(_doprnt HAVE_DOPRNT)

check_include_file("fcntl.h" HAVE_FCNTL_H)

check_symbol_exists("fstatfs" "sys/vfs.h" HAVE_FSTATFS)

check_symbol_exists("fstatvfs" "sys/statvfs.h" HAVE_FSTATVFS)

check_freetype_symbol_exists(FT_Done_MM_Var HAVE_FT_DONE_MM_VAR)

check_freetype_symbol_exists(FT_Get_BDF_Property HAVE_FT_GET_BDF_PROPERTY)

check_freetype_symbol_exists(FT_Get_PS_Font_Info HAVE_FT_GET_PS_FONT_INFO)

check_freetype_symbol_exists(FT_Get_X11_Font_Format HAVE_FT_GET_X11_FONT_FORMAT)

check_freetype_symbol_exists(FT_Has_PS_Glyph_Names HAVE_FT_HAS_PS_GLYPH_NAMES)

check_symbol_exists("getexecname" "stdlib.h" HAVE_GETEXECNAME)

check_symbol_exists("getopt" "unistd.h" HAVE_GETOPT)

check_symbol_exists("getopt_long" "getopt.h" HAVE_GETOPT_LONG)

check_symbol_exists("getpagesize" "unistd.h" HAVE_GETPAGESIZE)

check_symbol_exists("getprogname" "stdlib.h" HAVE_GETPROGNAME)

check_symbol_exists("gettext" "libintl.h" HAVE_GETTEXT)

check_symbol_exists("iconv" "iconv.h" HAVE_ICONV)

try_compile_intel_atomic_primitives(HAVE_INTEL_ATOMIC_PRIMITIVES)

check_include_file("inttypes.h" HAVE_INTTYPES_H)

check_symbol_exists("link" "unistd.h" HAVE_LINK)

check_symbol_exists("lrand48" "stdlib.h" HAVE_LRAND48)

check_symbol_exists("lstat" "sys/types.h;sys/stat.h;unistd.h" HAVE_LSTAT)

check_include_file("memory.h" HAVE_MEMORY_H)

check_symbol_exists("mkdtemp" "stdlib.h" HAVE_MKDTEMP)

check_symbol_exists("mkostemp" "stdlib.h" HAVE_MKOSTEMP)

check_symbol_exists("mkstemp" "stdlib.h" HAVE_MKSTEMP)

check_symbol_exists("mmap" "sys/mman.h" HAVE_MMAP)

check_include_file("ndir.h" HAVE_NDIR_H)

check_symbol_exists("posix_fadvise" "fcntl.h" HAVE_POSIX_FADVISE)

#/* Have POSIX threads */
#/* Have PTHREAD_PRIO_INHERIT. */
# Code from:
# https://github.com/webmproject/libwebp/blob/master/cmake/deps.cmake
# https://stackoverflow.com/a/29871891
set(CMAKE_THREAD_PREFER_PTHREAD ON)
find_package(Threads QUIET)
if(Threads_FOUND AND CMAKE_USE_PTHREADS_INIT)
  set(HAVE_PTHREAD 1)

  foreach(PTHREAD_TEST HAVE_PTHREAD_PRIO_INHERIT PTHREAD_CREATE_UNDETACHED)
    check_c_source_compiles(
      "
          #include <pthread.h>
          int main (void) {
            int attr = ${PTHREAD_TEST};
            return attr;
          }
      "
      ${PTHREAD_TEST}
    )
  endforeach()
endif()
# TODO
#/* Have PTHREAD_PRIO_INHERIT. */
#check_symbol_exists(PTHREAD_PRIO_INHERIT "pthread.h" HAVE_PTHREAD_PRIO_INHERIT)

check_symbol_exists("rand" "stdlib.h" HAVE_RAND)

check_symbol_exists("random" "stdlib.h" HAVE_RANDOM)

check_symbol_exists("random_r" "stdlib.h" HAVE_RANDOM_R)

check_symbol_exists("rand_r" "stdlib.h" HAVE_RAND_R)

check_symbol_exists("readlink" "unistd.h" HAVE_READLINK)

check_include_file("sched.h" HAVE_SCHED_H)

check_symbol_exists("sched_yield" "sched.h" HAVE_SCHED_YIELD)

try_compile_solaris_atomic_ops(HAVE_SOLARIS_ATOMIC_OPS)

check_include_file("stdint.h" HAVE_STDINT_H)

check_include_file("stdlib.h" HAVE_STDLIB_H)

check_include_file("strings.h" HAVE_STRINGS_H)

check_include_file("string.h" HAVE_STRING_H)

check_struct_has_member("struct dirent" d_type sys/dir.h
  HAVE_STRUCT_DIRENT_D_TYPE LANGUAGE C
)

check_struct_has_member("struct statfs" f_flags sys/statfs.h
  HAVE_STRUCT_STATFS_F_FLAGS LANGUAGE C
)

check_struct_has_member("struct statfs" f_fstypename sys/statfs.h
  HAVE_STRUCT_STATFS_F_FSTYPENAME LANGUAGE C
)

check_struct_has_member("struct statvfs" f_basetype sys/statvfs.h
  HAVE_STRUCT_STATVFS_F_BASETYPE LANGUAGE C
)

check_struct_has_member("struct statvfs" f_fstypename sys/statvfs.h
  HAVE_STRUCT_STATVFS_F_FSTYPENAME LANGUAGE C
)

check_struct_has_member("struct stat" st_mtim sys/stat.h
  HAVE_STRUCT_STAT_ST_MTIM LANGUAGE C
)

check_include_file("sys/dir.h" HAVE_SYS_DIR_H)

check_include_file("sys/mount.h" HAVE_SYS_MOUNT_H)

check_include_file("sys/ndir.h" HAVE_SYS_NDIR_H)

check_include_file("sys/param.h" HAVE_SYS_PARAM_H)

check_include_file("sys/statfs.h" HAVE_SYS_STATFS_H)

check_include_file("sys/statvfs.h" HAVE_SYS_STATVFS_H)

check_include_file("sys/stat.h" HAVE_SYS_STAT_H)

check_include_file("sys/types.h" HAVE_SYS_TYPES_H)

check_include_file("sys/vfs.h" HAVE_SYS_VFS_H)

check_include_file("unistd.h" HAVE_UNISTD_H)

check_symbol_exists("vprintf" "stdarg.h" HAVE_VPRINTF)

#/* Can use #warning in C files */
#cmakedefine HAVE_WARNING_CPP_DIRECTIVE @HAVE_WARNING_CPP_DIRECTIVE@

check_include_file("xmlparse.h" HAVE_XMLPARSE_H)

# TODO: replace check_function_exists() with check_symbol_exists()
# TODO: What is header file for XML_SetDoctypeDeclHandler to check_symbol_exists()?
check_function_exists(XML_SetDoctypeDeclHandler HAVE_XML_SETDOCTYPEDECLHANDLER)

check_symbol_exists("_mktemp_s" "io.h" HAVE__MKTEMP_S)

#/* Define to the sub-directory in which libtool stores uninstalled libraries.
#   */
#cmakedefine LT_OBJDIR @LT_OBJDIR@

#/* Name of package */
set(PACKAGE "\"fontconfig\"")

#/* Define to the address where bug reports for this package should be sent. */
set(PACKAGE_BUGREPORT
  "\"https://bugs.freedesktop.org/enter_bug.cgi?product=fontconfig\"")

#/* Define to the full name of this package. */
set(PACKAGE_NAME "\"fontconfig\"")

#/* Define to the full name and version of this package. */
set(PACKAGE_STRING "\"fontconfig ${fc_VERSION}\"")

#/* Define to the one symbol short name of this package. */
set(PACKAGE_TARNAME "\"fontconfig\"")

#/* Define to the home page for this package. */
set(PACKAGE_URL "\"\"")

#/* Define to the version of this package. */
set(PACKAGE_VERSION "\"${fc_VERSION}\"")

#/* Define to necessary symbol if this constant uses a non-standard name on
#   your system. */
check_symbol_exists(PTHREAD_CREATE_JOINABLE "pthread.h"
  _PTHREAD_CREATE_JOINABLE
)
if(_PTHREAD_CREATE_JOINABLE)
  set(PTHREAD_CREATE_JOINABLE "PTHREAD_CREATE_JOINABLE")
endif()


check_type_size("char"   SIZEOF_CHAR BUILTIN_TYPES_ONLY)

check_type_size("int"    SIZEOF_INT BUILTIN_TYPES_ONLY)

check_type_size("long"   SIZEOF_LONG BUILTIN_TYPES_ONLY)

check_type_size("short"  SIZEOF_SHORT BUILTIN_TYPES_ONLY)

check_type_size("void*"  SIZEOF_VOIDP BUILTIN_TYPES_ONLY)

check_type_size("void *" SIZEOF_VOID_P BUILTIN_TYPES_ONLY)

#/* Define to 1 if you have the ANSI C header files. */
check_include_files("stdlib.h;stdarg.h;string.h;float.h" STDC_HEADERS)

#/* Use iconv. */
#cmakedefine USE_ICONV @USE_ICONV@

#/* Use regex */
#cmakedefine USE_REGEX @USE_REGEX@

#/* Enable extensions on AIX 3, Interix.  */
#ifndef _ALL_SOURCE
# define _ALL_SOURCE
#endif
#if(Linux)
if(UNIX AND NOT APPLE)
  set(_GNU_SOURCE 1)
endif()
if(Solaris)
  set(_POSIX_PTHREAD_SEMANTICS 1)
endif()
#/* Enable extensions on HP NonStop.  */
#ifndef _TANDEM_SOURCE
# define _TANDEM_SOURCE
#endif
if(Solaris)
  set(__EXTENSIONS__ 1)
endif()

#/* Version number of package */
set(VERSION "\"${fc_VERSION}\"")

#/* Number of bits in a file offset, on hosts where this is settable. */
check_file_offset_bits()

#/* Define for large files, on AIX-style hosts. */
#test_large_files() set _LARGE_FILES to 1 if success.
test_large_files(HAVE_OFF_T_64_FSEEKO_FTELLO)

#/* Define to 1 if on MINIX. */
check_symbol_exists(_MINIX "stdio.h" _MINIX)

#/* Define to 2 if the system does not provide POSIX.1 features except with
#   this defined. */
check_symbol_exists(_POSIX_1_SOURCE "stdio.h" _POSIX_1_SOURCE)

#/* Define to 1 if you need to in order for `stat' and other things to work. */
check_symbol_exists(_POSIX_SOURCE "stdio.h" _POSIX_SOURCE)

#/* Define to empty if `const' does not conform to ANSI C. */
#cmakedefine const

#/* Define to `__inline__' or `__inline' if that's what the C compiler
#   calls it, or to nothing if 'inline' is not supported under any name.  */
set(inline_KEYWORD ${C_INLINE_KEYWORD}) # Set in include(CMakeTestInline)

#/* Define to `int' if <sys/types.h> does not define. */
check_type_exists(pid_t pid_t "sys/types.h" int)



check_symbol_exists("chsize" "io.h" HAVE_CHSIZE)
check_symbol_exists("ftruncate" "unistd.h;sys/types.h" HAVE_FTRUNCATE)
check_symbol_exists("geteuid" "unistd.h;sys/types.h" HAVE_GETEUID)
check_symbol_exists("getuid" "unistd.h;sys/types.h" HAVE_GETUID)
check_symbol_exists("memmove" "string.h" HAVE_MEMMOVE)
check_symbol_exists("memset" "string.h" HAVE_MEMSET)
check_symbol_exists("strchr" "string.h" HAVE_STRCHR)
check_symbol_exists("strrchr" "string.h" HAVE_STRRCHR)
check_symbol_exists("strtol" "stdlib.h" HAVE_STRTOL)
check_symbol_exists("sysconf" "unistd.h" HAVE_SYSCONF)



configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/config.h.in.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/config.h
)
