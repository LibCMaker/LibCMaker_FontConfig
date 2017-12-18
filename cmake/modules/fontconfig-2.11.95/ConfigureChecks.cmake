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

# Checking Headers and Functions for fontconfig

include(CheckIncludeFile)
include(CheckFunctionExists)
include(CheckStructHasMember)
include(CheckSymbolExists)
include(CheckTypeSize)


macro(check_freetype_struct_has_member struct member out_var)
  file(WRITE "${PROJECT_BINARY_DIR}/try_compile_${struct}_${member}.c"
  "
      #include <ft2build.h>
      #include FT_FREETYPE_H

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
  )
  if(_${out_var})
    set(${out_var} 1)
    set(is_found_msg "found")
  else()
    set(is_found_msg "not found")
  endif()
  message(STATUS "Looking for ${out_var} - ${is_found_msg}")
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
      "-DLINK_DIRECTORIES=${CMAKE_INSTALL_PREFIX}/lib"
    LINK_LIBRARIES freetype
  )

  if(_${out_var})
    set(${out_var} 1)
    set(is_found_msg "found")
  else()
    set(is_found_msg "not found")
  endif()
  
  message(STATUS "Looking for ${out_var} - ${is_found_msg}")
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
  )
  if(_${out_var})
    set(${out_var} 1)
    set(is_found_msg "found")
  else()
    set(is_found_msg "not found")
  endif()
  message(STATUS "Looking for ${out_var} - ${is_found_msg}")
endmacro()


if(WIN32)
  if(MSVC)
    set(CMAKE_REQUIRED_INCLUDES ${CMAKE_INCLUDE_PATH} ${CMAKE_INCLUDE_PATH}/msvc)
  else()
    set(CMAKE_REQUIRED_INCLUDES ${CMAKE_INCLUDE_PATH} ${CMAKE_INCLUDE_PATH}/mingw)
  endif()
endif()


list(APPEND CMAKE_REQUIRED_INCLUDES
  ${EXPAT_INCLUDE_DIR} ${FREETYPE_INCLUDE_DIR}
)
list(APPEND CMAKE_REQUIRED_LIBRARIES
  ${EXPAT_LIBRARIES} ${FREETYPE_LIBRARIES}
)


#/* Define if building universal (internal helper macro) */
#cmakedefine AC_APPLE_UNIVERSAL_BUILD @AC_APPLE_UNIVERSAL_BUILD@

# TODO: fix this alignof tests
check_type_size("double" ALIGNOF_DOUBLE)
check_type_size("void *" ALIGNOF_VOID_P)

#/* Use libxml2 instead of Expat */
#cmakedefine ENABLE_LIBXML2 @ENABLE_LIBXML2@

#/* Additional font directories */
#cmakedefine FC_ADD_FONTS "yes"

#/* Architecture prefix to use for cache file names */
#cmakedefine FC_ARCHITECTURE @FC_ARCHITECTURE@

set(FC_DEFAULT_FONTS "\"%WINDIR%\\fonts\"") # TODO: others OS

#/* Define to nothing if C supports flexible array members, and to 1 if it does
#   not. That way, with a declaration like `struct s { int n; double
#   d[FLEXIBLE_ARRAY_MEMBER]; };', the struct hack can be used with pre-C99
#   compilers. When computing the size of such an object, don't use 'sizeof
#   (struct s)' as it overestimates the size. Use 'offsetof (struct s, d)'
#   instead. Don't use 'offsetof (struct s, d[0])', as this doesn't work with
#   MSVC and with C++ compilers. */
#define FLEXIBLE_ARRAY_MEMBER

check_include_file("dirent.h" HAVE_DIRENT_H)

check_include_file("dlfcn.h" HAVE_DLFCN_H)

check_function_exists(_doprnt HAVE_DOPRNT)

check_include_file("fcntl.h" HAVE_FCNTL_H)

check_function_exists(fstatfs HAVE_FSTATFS)

check_function_exists(fstatvfs HAVE_FSTATVFS)

check_freetype_struct_has_member(
  FT_Bitmap_Size y_ppem HAVE_FT_BITMAP_SIZE_Y_PPEM
)

check_freetype_symbol_exists(FT_Get_BDF_Property HAVE_FT_GET_BDF_PROPERTY)

check_freetype_symbol_exists(FT_Get_Next_Char HAVE_FT_GET_NEXT_CHAR)

check_freetype_symbol_exists(FT_Get_PS_Font_Info HAVE_FT_GET_PS_FONT_INFO)

check_freetype_symbol_exists(FT_Get_X11_Font_Format HAVE_FT_GET_X11_FONT_FORMAT)

check_freetype_symbol_exists(FT_Has_PS_Glyph_Names HAVE_FT_HAS_PS_GLYPH_NAMES)

check_freetype_symbol_exists(FT_Select_Size HAVE_FT_SELECT_SIZE)

check_function_exists(getexecname HAVE_GETEXECNAME)

check_function_exists(getopt HAVE_GETOPT)

check_function_exists(getopt_long HAVE_GETOPT_LONG)

check_function_exists(getpagesize HAVE_GETPAGESIZE)

check_function_exists(getprogname HAVE_GETPROGNAME)

try_compile_intel_atomic_primitives(HAVE_INTEL_ATOMIC_PRIMITIVES)

check_include_file("inttypes.h" HAVE_INTTYPES_H)

check_function_exists(link HAVE_LINK)

check_function_exists(lrand48 HAVE_LRAND48)

check_function_exists(lstat HAVE_LSTAT)

check_include_file("memory.h" HAVE_MEMORY_H)

check_function_exists(mkdtemp HAVE_MKDTEMP)

check_function_exists(mkostemp HAVE_MKOSTEMP)

check_function_exists(mkstemp HAVE_MKSTEMP)

check_function_exists(mmap HAVE_MMAP)

check_include_file("ndir.h" HAVE_NDIR_H)

check_function_exists(posix_fadivse HAVE_POSIX_FADVISE)

#/* Have POSIX threads */
#cmakedefine HAVE_PTHREAD @HAVE_PTHREAD@

#/* Have PTHREAD_PRIO_INHERIT. */
#cmakedefine HAVE_PTHREAD_PRIO_INHERIT @HAVE_PTHREAD_PRIO_INHERIT@

check_function_exists(rand HAVE_RAND)

check_function_exists(random HAVE_RANDOM)

check_function_exists(random_r HAVE_RANDOM_R)

check_function_exists(rand_r HAVE_RAND_R)

check_function_exists(readlink HAVE_READLINK)

check_function_exists(regcomp HAVE_REGCOMP)

check_function_exists(regerror HAVE_REGERROR)

check_function_exists(regexec HAVE_REGEXEC)

check_include_file("regex.h" HAVE_REGEX_H)

check_function_exists(regfree HAVE_REGFREE)

check_function_exists(scandir HAVE_SCANDIR)

#/* Define to 1 if you have the 'scandir' function with int (* compar)(const
#   void *, const void *) */
#cmakedefine HAVE_SCANDIR_VOID_P @HAVE_SCANDIR_VOID_P@

check_include_file("sched.h" HAVE_SCHED_H)

#/* Have sched_yield */
#cmakedefine HAVE_SCHED_YIELD @HAVE_SCHED_YIELD@

#/* Have Solaris __machine_*_barrier and atomic_* operations */
#cmakedefine HAVE_SOLARIS_ATOMIC_OPS @HAVE_SOLARIS_ATOMIC_OPS@

check_include_file("stdint.h" HAVE_STDINT_H)

check_include_file("stdlib.h" HAVE_STDLIB_H)

check_include_file("strings.h" HAVE_STRINGS_H)

check_include_file("string.h" HAVE_STRING_H)

#/* Define to 1 if `d_type' is a member of `struct dirent'. */
#cmakedefine HAVE_STRUCT_DIRENT_D_TYPE @HAVE_STRUCT_DIRENT_D_TYPE@

#/* Define to 1 if `f_flags' is a member of `struct statfs'. */
#cmakedefine HAVE_STRUCT_STATFS_F_FLAGS @HAVE_STRUCT_STATFS_F_FLAGS@

#/* Define to 1 if `f_fstypename' is a member of `struct statfs'. */
#cmakedefine HAVE_STRUCT_STATFS_F_FSTYPENAME @HAVE_STRUCT_STATFS_F_FSTYPENAME@

#/* Define to 1 if `f_basetype' is a member of `struct statvfs'. */
#cmakedefine HAVE_STRUCT_STATVFS_F_BASETYPE @HAVE_STRUCT_STATVFS_F_BASETYPE@

#/* Define to 1 if `f_fstypename' is a member of `struct statvfs'. */
#cmakedefine HAVE_STRUCT_STATVFS_F_FSTYPENAME @HAVE_STRUCT_STATVFS_F_FSTYPENAME@

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

#/* Define to 1 if `usLowerOpticalPointSize' is a member of `TT_OS2'. */
#cmakedefine HAVE_TT_OS2_USLOWEROPTICALPOINTSIZE @HAVE_TT_OS2_USLOWEROPTICALPOINTSIZE@

#/* Define to 1 if `usUpperOpticalPointSize' is a member of `TT_OS2'. */
#cmakedefine HAVE_TT_OS2_USUPPEROPTICALPOINTSIZE @HAVE_TT_OS2_USUPPEROPTICALPOINTSIZE@

check_include_file("unistd.h" HAVE_UNISTD_H)

check_function_exists(vprintf HAVE_VPRINTF)

#/* Can use #warning in C files */
#cmakedefine HAVE_WARNING_CPP_DIRECTIVE @HAVE_WARNING_CPP_DIRECTIVE@

check_include_file("xmlparse.h" HAVE_XMLPARSE_H)

check_function_exists(XML_SetDoctypeDeclHandler HAVE_XML_SETDOCTYPEDECLHANDLER)

check_function_exists(_mktemp_s HAVE__MKTEMP_S)

#/* Define to the sub-directory in which libtool stores uninstalled libraries.
#   */
#cmakedefine LT_OBJDIR @LT_OBJDIR@

#/* Name of package */
#define PACKAGE "fontconfig"

#/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT

#/* Define to the full name of this package. */
#define PACKAGE_NAME "fontconfig"

#/* Define to the full name and version of this package. */
#define PACKAGE_STRING "fontconfig"

#/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME ""

#/* Define to the home page for this package. */
#define PACKAGE_URL ""

#/* Define to the version of this package. */
#cmakedefine PACKAGE_VERSION 1

#/* Define to necessary symbol if this constant uses a non-standard name on
#   your system. */
#cmakedefine PTHREAD_CREATE_JOINABLE @PTHREAD_CREATE_JOINABLE@

check_type_size("char"   SIZEOF_CHAR BUILTIN_TYPES_ONLY)

check_type_size("int"    SIZEOF_INT BUILTIN_TYPES_ONLY)

check_type_size("long"   SIZEOF_LONG BUILTIN_TYPES_ONLY)

check_type_size("short"  SIZEOF_SHORT BUILTIN_TYPES_ONLY)

check_type_size("void*"  SIZEOF_VOIDP BUILTIN_TYPES_ONLY)

check_type_size("void *" SIZEOF_VOID_P BUILTIN_TYPES_ONLY)

#/* Define to 1 if you have the ANSI C header files. */
#cmakedefine STDC_HEADERS @STDC_HEADERS@

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
#cmakedefine VERSION @VERSION@

set(_FILE_OFFSET_BITS 64) # TODO

#/* Define for large files, on AIX-style hosts. */
#cmakedefine _LARGE_FILES

#/* Define to 1 if on MINIX. */
#cmakedefine _MINIX

#/* Define to 2 if the system does not provide POSIX.1 features except with
#   this defined. */
#cmakedefine _POSIX_1_SOURCE

if(UNIX AND NOT APPLE)
  set(_POSIX_SOURCE 1)
endif()

#/* Define to empty if `const' does not conform to ANSI C. */
#cmakedefine const

#/* Define to `__inline__' or `__inline' if that's what the C compiler
#   calls it, or to nothing if 'inline' is not supported under any name.  */
#ifndef __cplusplus
#undef inline
#endif

#/* Define to `int' if <sys/types.h> does not define. */
#cmakedefine pid_t



check_function_exists(chsize HAVE_CHSIZE)
check_function_exists(ftruncate HAVE_FTRUNCATE)
check_function_exists(geteuid HAVE_GETEUID)
check_function_exists(getuid HAVE_GETUID)
check_function_exists(memmove HAVE_MEMMOVE)
check_function_exists(memset HAVE_MEMSET)
check_function_exists(strchr HAVE_STRCHR)
check_function_exists(strrchr HAVE_STRRCHR)
check_function_exists(strtol HAVE_STRTOL)
check_function_exists(sysconf HAVE_SYSCONF)

#set(ALIGNOF_DOUBLE 8)
#set(ALIGNOF_VOID_P ${CMAKE_SIZEOF_VOID_P}) # It is hack.
#set(HAVE_INTEL_ATOMIC_PRIMITIVES 1)



#add_definitions(-DHAVE_CONFIG_H)
#add_definitions(-DFONTCONFIG_PATH="\\"${CMAKE_INSTALL_PREFIX}/etc/fonts\\"")

set(FC_CACHEDIR "\"%TEMP%\\fc_cache\"")
#TODO: add_definitions(-DFC_CACHEDIR="\"%TEMP%\\fc_cache\"")

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/config.h.in.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/config.h
)
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/fonts.conf.in.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/fonts.conf
)

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/fonts.conf
  DESTINATION etc/fonts
)
