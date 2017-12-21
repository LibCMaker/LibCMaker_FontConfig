/*
 Code from:
 fontconfig-2.11.95/fc-query/fc-query.c
*/

/*
 * fontconfig/fc-query/fc-query.c
 *
 * Copyright © 2003 Keith Packard
 * Copyright © 2008 Red Hat, Inc.
 * Red Hat Author(s): Behdad Esfahbod
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of the author(s) not be used in
 * advertising or publicity pertaining to distribution of the software without
 * specific, written prior permission.  The authors make no
 * representations about the suitability of this software for any purpose.  It
 * is provided "as is" without express or implied warranty.
 *
 * THE AUTHOR(S) DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
 * EVENT SHALL THE AUTHOR(S) BE LIABLE FOR ANY SPECIAL, INDIRECT OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
 * DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <fontconfig/fontconfig.h>
#include <fontconfig/fcfreetype.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>


static void
usage (char *program, int error)
{
    FILE *file = error ? stderr : stdout;
    fprintf (file, "usage: %s [-Vbh] [-i index] [-f FORMAT] font-file...\n",
	     program);
    fprintf (file, "Query font files and print resulting pattern(s)\n");
    fprintf (file, "\n");
    fprintf (file, "  -b         (ignore-blanks) ignore blanks to compute languages\n");
    fprintf (file, "  -i INDEX   (index)         display the INDEX face of each font file only\n");
    fprintf (file, "  -f FORMAT  (format)        use the given output format\n");
    fprintf (file, "  -V         (version)       display font config version and exit\n");
    fprintf (file, "  -h         (help)          display this help and exit\n");
    exit (error);
}

int
main (int argc, char **argv)
{
    int		index_set = 0;
    int		set_index = 0;
    int		ignore_blanks = 0;
    FcChar8     *format = NULL;
    FcBlanks    *blanks = NULL;
    int		err = 0;
    int		i;
    i = 1;

    if (i == argc)
	usage (argv[0], 1);

    if (!ignore_blanks)
	blanks = FcConfigGetBlanks (NULL);
    for (; i < argc; i++)
    {
	int index;
	int count = 0;

	index = set_index;

	do {
	    FcPattern *pat;

	    pat = FcFreeTypeQuery ((FcChar8 *) argv[i], index, blanks, &count);
	    if (pat)
	    {
		if (format)
		{
		    FcChar8 *s;

		    s = FcPatternFormat (pat, format);
		    if (s)
		    {
			printf ("%s", s);
			FcStrFree (s);
		    }
		}
		else
		{
		    FcPatternPrint (pat);
		}

		FcPatternDestroy (pat);
	    }
	    else
	    {
		fprintf (stderr, "Can't query face %d of font file %s\n",
			 index, argv[i]);
		err = 1;
	    }

	    index++;
	} while (!index_set && index < count);
    }

    FcFini ();
    return err;
}
