/*
 * dis6502 by Robert Bond, Udi Finkelstein, and Eric Smith
 *
 * Copyright 2001-2018 Eric Smith <spacewar@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.  Note that permission is
 * not granted to redistribute this program under the terms of any
 * other version of the General Public License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA
 */


%{
#undef ECHO
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "dis.h"
int lineno = 0;
char *strcpy();
%}

%option nounput
%option noinput

digit		[0-9]
hexdigit	[0-9a-fA-F]
alpha		[a-zA-Z]
alphanum	[0-9a-zA-Z_]

%%

[ \t]			{ ; }

[\n]			{ lineno++; return '\n'; }

\.[Ee][Qq][Uu]		{ return EQ; }

\.[Ee][Qq]		{ return EQ; }

\.[Ee][Qq][Ss]		{ return EQS; }

\.[Oo][Ff][Ss]		{ return OFS; }

\.[Ll][Ii]		{ return LI; }

\.[Tt][Rr][Aa][Cc][Ee]	{ return TSTART; }

\.[Ss][Tt][Oo][Pp]	{ return TSTOP; }

\.[Rr][Tt][Ss][Tt][Aa][Bb]	{ return TRTSTAB; }

\.[Jj][Tt][Aa][Bb]2	{ return TJTAB2; }

\.[Jj][Tt][Aa][Bb]	{ return TJTAB; }

{digit}+		{
			  (void)sscanf(yytext, "%d", &token.ival); 
			  return NUMBER;
			}

\${hexdigit}+		{
			  (void)sscanf(yytext+1, "%x", &token.ival);
			  return NUMBER;
			}

{alpha}{alphanum}*	{
			  token.sval = emalloc((unsigned) strlen(yytext)+1);
			  (void)strcpy((char *)token.sval, (char *)yytext);
			  return NAME;
			}
\*.*			{
			  return COMMENT;
			}
\;.*			{
			  return COMMENT;
			}

.			{ return yytext[0]; }

%%

char *
emalloc(n)
unsigned n;
{
	char *ptr;

	if ((ptr = malloc(n)) == (char *) 0) {
		(void) fprintf(stderr,"out of core");
		exit(1);
	}
	return ptr;
}
