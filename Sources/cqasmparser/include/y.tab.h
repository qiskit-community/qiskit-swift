/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     OPENQASM = 258,
     NNINTEGER = 259,
     BARRIER = 260,
     OPAQUE = 261,
     RESET = 262,
     IF = 263,
     REAL = 264,
     QREG = 265,
     CREG = 266,
     GATE = 267,
     PI = 268,
     CX = 269,
     U = 270,
     MEASURE = 271,
     MATCHES = 272,
     ID = 273,
     INCLD = 274,
     STRING = 275,
     ASSIGN = 276,
     SIN = 277,
     COS = 278,
     TAN = 279,
     EXP = 280,
     LN = 281,
     SQRT = 282
   };
#endif
/* Tokens.  */
#define OPENQASM 258
#define NNINTEGER 259
#define BARRIER 260
#define OPAQUE 261
#define RESET 262
#define IF 263
#define REAL 264
#define QREG 265
#define CREG 266
#define GATE 267
#define PI 268
#define CX 269
#define U 270
#define MEASURE 271
#define MATCHES 272
#define ID 273
#define INCLD 274
#define STRING 275
#define ASSIGN 276
#define SIN 277
#define COS 278
#define TAN 279
#define EXP 280
#define LN 281
#define SQRT 282




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 12 "parser.y"
{
    int ivalue;
    double fvalue;
    long svalue;
    long node;
}
/* Line 1529 of yacc.c.  */
#line 110 "y.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

