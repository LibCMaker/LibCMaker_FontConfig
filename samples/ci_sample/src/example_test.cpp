/*****************************************************************************
 * Project:  LibCMaker_STLCache
 * Purpose:  A CMake build script for STLCache library
 * Author:   NikitaFeodonit, nfeodonit@yandex.com
 *****************************************************************************
 *   Copyright (c) 2017-2019 NikitaFeodonit
 *
 *    This file is part of the LibCMaker_STLCache project.
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published
 *    by the Free Software Foundation, either version 3 of the License,
 *    or (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *    See the GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program. If not, see <http://www.gnu.org/licenses/>.
 ****************************************************************************/

// The code is based on the code from
// <fontconfig>/fc-list/fc-list.c

#include <fontconfig/fontconfig.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include "gtest/gtest.h"

TEST(Examle, test)
{
  int verbose = 0;
  int quiet = 0;
  const FcChar8 *format = NULL;
  int nfont = 0;
  FcObjectSet *os = 0;
  FcFontSet *fs;
  FcPattern *pat;

  pat = FcPatternCreate();

  if (quiet && !os)
    os = FcObjectSetCreate();
  if (!verbose && !format && !os)
    os = FcObjectSetBuild(FC_FAMILY, FC_STYLE, FC_FILE, (char *)0);
  if (!format)
    format = (const FcChar8 *)"%{=fclist}\n";
  fs = FcFontList(0, pat, os);
  if (os)
    FcObjectSetDestroy(os);
  if (pat)
    FcPatternDestroy(pat);

  if (!quiet && fs) {
    int j;

    for (j = 0; j < fs->nfont; j++) {
      if (verbose) {
        FcPatternPrint(fs->fonts[j]);
      } else {
        FcChar8 *s;

        s = FcPatternFormat(fs->fonts[j], format);
        if (s) {
          printf("%s", s);
          FcStrFree(s);
        }
      }
    }
  }

  if (fs) {
    nfont = fs->nfont;
    FcFontSetDestroy(fs);
  }

  FcFini();

  EXPECT_EQ(quiet ? (nfont == 0 ? 1 : 0) : 0, 0);
}
