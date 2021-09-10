/*
 Code from:
 fontconfig-2.11.95/fc-list/fc-list.c
*/

/*
 * fontconfig/fc-list/fc-list.c
 *
 * Copyright © 2002 Keith Packard
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

#include <fontconfig/fontconfig.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

static void
usage (char *program, int error)
{
    FILE *file = error ? stderr : stdout;
    fprintf (file, "usage: %s [-vqVh] [-f FORMAT] [pattern] {element ...} \n",
	     program);
    fprintf (file, "List fonts matching [pattern]\n");
    fprintf (file, "\n");
    fprintf (file, "  -v         (verbose) display entire font pattern verbosely\n");
    fprintf (file, "  -f FORMAT  (format)  use the given output format\n");
    fprintf (file, "  -q,        (quiet)   suppress all normal output, exit 1 if no fonts matched\n");
    fprintf (file, "  -V         (version) display font config version and exit\n");
    fprintf (file, "  -h         (help)    display this help and exit\n");
    exit (error);
}

int
main (int argc, char **argv)
{
    int			verbose = 0;
    int			quiet = 0;
    const FcChar8	*format = NULL;
    int			nfont = 0;
    int			i;
    FcObjectSet		*os = 0;
    FcFontSet		*fs;
    FcPattern		*pat;
    i = 1;

    if (argv[i])
    {
	pat = FcNameParse ((FcChar8 *) argv[i]);
	if (!pat)
	{
	    fputs ("Unable to parse the pattern\n", stderr);
	    return 1;
	}
	while (argv[++i])
	{
	    if (!os)
		os = FcObjectSetCreate ();
	    FcObjectSetAdd (os, argv[i]);
	}
    }
    else
	pat = FcPatternCreate ();
    if (quiet && !os)
	os = FcObjectSetCreate ();
    if (!verbose && !format && !os)
	os = FcObjectSetBuild (FC_FAMILY, FC_STYLE, FC_FILE, (char *) 0);
    if (!format)
        format = (const FcChar8 *) "%{=fclist}\n";
    fs = FcFontList (0, pat, os);
    if (os)
	FcObjectSetDestroy (os);
    if (pat)
	FcPatternDestroy (pat);

    if (!quiet && fs)
    {
	int	j;

	for (j = 0; j < fs->nfont; j++)
	{
	    if (verbose)
	    {
		FcPatternPrint (fs->fonts[j]);
	    }
	    else
	    {
	        FcChar8 *s;

		s = FcPatternFormat (fs->fonts[j], format);
		if (s)
		{
		    printf ("%s", s);
		    FcStrFree (s);
		}
	    }
	}
    }

    if (fs) {
	nfont = fs->nfont;
	FcFontSetDestroy (fs);
    }

    FcFini ();

    return quiet ? (nfont == 0 ? 1 : 0) : 0;
}
