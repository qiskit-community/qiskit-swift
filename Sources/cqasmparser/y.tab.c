/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C

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

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.3"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Using locations.  */
#define YYLSP_NEEDED 0



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




/* Copy the first part of user declarations.  */
#line 1 "parser.y"


#include "ParseTree.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"

int yylex(void);
void yyerror(char *s);



/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif

#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 12 "parser.y"
{
    int ivalue;
    double fvalue;
    long svalue;
    long node;
}
/* Line 193 of yacc.c.  */
#line 168 "y.tab.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 181 "y.tab.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int i)
#else
static int
YYID (i)
    int i;
#endif
{
  return i;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  6
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   226

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  42
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  41
/* YYNRULES -- Number of rules.  */
#define YYNRULES  89
/* YYNRULES -- Number of states.  */
#define YYNSTATES  180

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   282

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      34,    35,    32,    30,    28,    31,     2,    33,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,    36,
       2,    29,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    37,     2,    38,    41,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    39,     2,    40,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     7,    12,    16,    18,    21,    23,    26,
      29,    31,    36,    38,    40,    42,    46,    48,    52,    54,
      58,    60,    64,    67,    70,    72,    75,    78,    83,    90,
      98,   102,   105,   107,   110,   116,   121,   124,   129,   135,
     142,   148,   152,   158,   165,   169,   173,   179,   186,   191,
     194,   197,   205,   207,   209,   211,   213,   215,   217,   219,
     221,   223,   225,   229,   234,   236,   239,   242,   244,   248,
     252,   254,   258,   262,   264,   268,   270,   274,   276,   278,
     280,   282,   284,   286,   288,   290,   292,   294,   296,   298
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int8 yyrhs[] =
{
      43,     0,    -1,    47,    36,    45,    -1,    47,    36,    44,
      45,    -1,    81,    80,    36,    -1,    46,    -1,    45,    46,
      -1,    55,    -1,    68,    36,    -1,     3,    76,    -1,    18,
      -1,    48,    37,    75,    38,    -1,    48,    -1,    49,    -1,
      48,    -1,    51,    28,    48,    -1,    48,    -1,    52,    28,
      48,    -1,    48,    -1,    53,    28,    48,    -1,    50,    -1,
      54,    28,    50,    -1,    56,    36,    -1,    57,    36,    -1,
      58,    -1,    10,    49,    -1,    11,    49,    -1,    12,    48,
      53,    59,    -1,    12,    48,    34,    35,    53,    59,    -1,
      12,    48,    34,    52,    35,    53,    59,    -1,    39,    60,
      40,    -1,    39,    40,    -1,    62,    -1,    60,    62,    -1,
      15,    34,    74,    35,    50,    -1,    14,    50,    28,    50,
      -1,    48,    54,    -1,    48,    34,    35,    54,    -1,    48,
      34,    74,    35,    54,    -1,    15,    34,    74,    35,    48,
      36,    -1,    14,    48,    28,    48,    36,    -1,    48,    51,
      36,    -1,    48,    34,    35,    51,    36,    -1,    48,    34,
      74,    35,    51,    36,    -1,     5,    51,    36,    -1,     6,
      48,    53,    -1,     6,    48,    34,    35,    53,    -1,     6,
      48,    34,    52,    35,    53,    -1,    16,    50,    78,    50,
      -1,     5,    54,    -1,     7,    50,    -1,     8,    34,    48,
      79,    75,    35,    68,    -1,    61,    -1,    63,    -1,    64,
      -1,    65,    -1,    66,    -1,    67,    -1,    75,    -1,    76,
      -1,    77,    -1,    48,    -1,    34,    73,    35,    -1,    48,
      34,    82,    35,    -1,    69,    -1,    30,    70,    -1,    31,
      70,    -1,    70,    -1,    71,    30,    70,    -1,    71,    31,
      70,    -1,    71,    -1,    72,    32,    71,    -1,    72,    33,
      71,    -1,    72,    -1,    73,    41,    72,    -1,    73,    -1,
      73,    28,    74,    -1,     4,    -1,     9,    -1,    13,    -1,
      21,    -1,    17,    -1,    20,    -1,    19,    -1,    22,    -1,
      23,    -1,    24,    -1,    25,    -1,    26,    -1,    27,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,    99,    99,   103,   111,   117,   118,   125,   126,   131,
     136,   141,   147,   148,   154,   155,   162,   163,   169,   170,
     177,   178,   186,   187,   188,   194,   199,   212,   213,   214,
     227,   228,   237,   238,   254,   255,   256,   257,   258,   271,
     272,   273,   274,   275,   276,   286,   287,   288,   293,   300,
     305,   315,   327,   328,   329,   330,   331,   332,   345,   346,
     347,   348,   349,   350,   356,   357,   358,   360,   361,   362,
     364,   365,   366,   368,   369,   375,   376,   381,   382,   383,
     385,   386,   387,   388,   390,   391,   392,   393,   394,   395
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "OPENQASM", "NNINTEGER", "BARRIER",
  "OPAQUE", "RESET", "IF", "REAL", "QREG", "CREG", "GATE", "PI", "CX", "U",
  "MEASURE", "MATCHES", "ID", "INCLD", "STRING", "ASSIGN", "SIN", "COS",
  "TAN", "EXP", "LN", "SQRT", "','", "'='", "'+'", "'-'", "'*'", "'/'",
  "'('", "')'", "';'", "'['", "']'", "'{'", "'}'", "'^'", "$accept",
  "mainprogram", "include", "program", "statement", "magic", "id",
  "indexed_id", "primary", "id_list", "gate_id_list", "bit_list",
  "primary_list", "decl", "qreg_decl", "creg_decl", "gate_decl",
  "gate_body", "gate_op_list", "unitary_op", "gate_op", "opaque",
  "measure", "barrier", "reset", "ifn", "quantum_op", "unary",
  "prefix_expression", "additive_expression", "multiplicative_expression",
  "expression", "exp_list", "nninteger", "real", "pi", "assign", "matches",
  "string", "incld", "external", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,    44,    61,
      43,    45,    42,    47,    40,    41,    59,    91,    93,   123,
     125,    94
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    42,    43,    43,    44,    45,    45,    46,    46,    47,
      48,    49,    50,    50,    51,    51,    52,    52,    53,    53,
      54,    54,    55,    55,    55,    56,    57,    58,    58,    58,
      59,    59,    60,    60,    61,    61,    61,    61,    61,    62,
      62,    62,    62,    62,    62,    63,    63,    63,    64,    65,
      66,    67,    68,    68,    68,    68,    68,    68,    69,    69,
      69,    69,    69,    69,    70,    70,    70,    71,    71,    71,
      72,    72,    72,    73,    73,    74,    74,    75,    76,    77,
      78,    79,    80,    81,    82,    82,    82,    82,    82,    82
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     3,     4,     3,     1,     2,     1,     2,     2,
       1,     4,     1,     1,     1,     3,     1,     3,     1,     3,
       1,     3,     2,     2,     1,     2,     2,     4,     6,     7,
       3,     2,     1,     2,     5,     4,     2,     4,     5,     6,
       5,     3,     5,     6,     3,     3,     5,     6,     4,     2,
       2,     7,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     3,     4,     1,     2,     2,     1,     3,     3,
       1,     3,     3,     1,     3,     1,     3,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,     0,     0,     0,    78,     9,     1,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    10,    83,
       0,     2,     5,     0,     7,     0,     0,    24,    52,    53,
      54,    55,    56,    57,     0,     0,    12,    13,    20,    49,
       0,    50,     0,     0,    25,    26,     0,     0,     0,     0,
       3,     6,     0,    36,    22,    23,     8,    82,     0,     0,
       0,     0,    18,    45,     0,     0,     0,     0,    77,    79,
       0,     0,     0,    61,    64,    67,    70,    73,    75,     0,
      58,    59,    60,    80,     0,     0,     0,     4,     0,    21,
       0,    16,     0,     0,    81,     0,     0,     0,     0,    27,
      35,    65,    66,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    48,    37,     0,    11,    46,     0,     0,    19,
       0,     0,     0,     0,     0,     0,    31,     0,     0,    32,
      62,    84,    85,    86,    87,    88,    89,     0,    68,    69,
      71,    72,    76,    74,    34,    38,    17,    47,     0,    28,
       0,    14,     0,     0,     0,     0,     0,    30,    33,    63,
      51,    29,     0,    44,     0,     0,     0,     0,    41,    15,
       0,     0,     0,     0,    40,     0,    42,     0,    39,    43
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     2,    20,    21,    22,     3,    73,    37,    38,   152,
      92,    63,    39,    24,    25,    26,    27,    99,   128,    28,
     129,    29,    30,    31,    32,    33,    34,    74,    75,    76,
      77,    78,    79,    80,    81,    82,    84,    95,    58,    35,
     137
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -119
static const yytype_int16 yypact[] =
{
      22,    29,    59,    34,  -119,  -119,  -119,   179,    47,    47,
      47,    40,    47,    47,    47,    47,    53,    47,  -119,  -119,
     194,   194,  -119,     8,  -119,    56,    61,  -119,  -119,  -119,
    -119,  -119,  -119,  -119,    76,    86,    30,  -119,  -119,    81,
      10,  -119,    47,    30,  -119,  -119,    39,    90,   149,   101,
     194,  -119,   115,    81,  -119,  -119,  -119,  -119,    95,   128,
      47,    -1,  -119,   120,   123,     2,    24,    47,  -119,  -119,
     149,   149,   149,   118,  -119,  -119,    51,    94,    -9,   119,
    -119,  -119,  -119,  -119,    47,    47,   125,  -119,   127,  -119,
      47,  -119,    70,    47,  -119,   128,    47,    73,    31,  -119,
    -119,  -119,  -119,   -11,   112,   149,   149,   149,   149,   149,
     149,    47,  -119,    81,    47,  -119,   120,    47,    47,  -119,
     126,    24,    47,    47,    47,   129,  -119,    46,    85,  -119,
    -119,  -119,  -119,  -119,  -119,  -119,  -119,   135,  -119,  -119,
      51,    51,  -119,    94,  -119,    81,  -119,   120,   208,  -119,
      24,  -119,    -5,   143,   149,   138,    33,  -119,  -119,  -119,
    -119,  -119,    47,  -119,    47,   139,    47,   140,  -119,  -119,
     141,    47,    57,    47,  -119,   142,  -119,    66,  -119,  -119
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -119,  -119,  -119,   156,    -3,  -119,    -7,   117,    12,  -118,
     116,   -34,   -19,  -119,  -119,  -119,  -119,  -100,  -119,  -119,
      54,  -119,  -119,  -119,  -119,  -119,    44,  -119,   -30,    36,
      78,   124,   -41,   -44,   202,  -119,  -119,  -119,  -119,  -119,
    -119
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const yytype_uint8 yytable[] =
{
      23,    36,    40,    36,    53,    43,    43,    46,    36,   156,
      36,    86,    66,    23,    23,    88,    36,    18,    51,   109,
      18,   149,    41,   162,   130,     1,    18,    47,    18,    49,
     110,   163,   110,    62,    90,    64,   123,    96,     4,    62,
     101,   102,    52,    23,    61,   124,   125,    51,   172,    18,
     161,   120,    93,    36,    91,   177,   116,    18,    91,     6,
      36,   162,   121,    98,    18,    18,   113,    59,   142,   168,
       7,   126,    89,    65,    42,   138,   139,    36,    36,   100,
     155,   105,   106,    62,   147,   162,   119,    48,   150,    62,
     123,   127,    54,   176,   162,   145,   112,    55,   117,   124,
     125,   117,   179,    18,    36,   118,    57,    36,   122,    60,
     146,    62,    56,   165,   167,    62,   151,   153,    67,    68,
     151,   127,    83,   144,     4,   157,   107,   108,    69,    44,
      45,    87,    68,    18,   131,   132,   133,   134,   135,   136,
      94,    23,    68,   140,   141,    70,    71,     4,    93,    72,
      85,    69,   104,    68,   111,   169,    18,   170,     4,   151,
     114,   148,    69,   154,   175,   115,   151,    18,    70,    71,
     159,   164,    72,   166,   171,   173,    50,   174,   178,    70,
      71,    97,   158,    72,     8,     9,    10,    11,   143,    12,
      13,    14,   160,    15,    16,    17,   103,    18,    19,     8,
       9,    10,    11,     5,    12,    13,    14,     0,    15,    16,
      17,     0,    18,     8,     9,    10,    11,     0,     0,     0,
       0,     0,    15,    16,    17,     0,    18
};

static const yytype_int16 yycheck[] =
{
       7,     8,     9,    10,    23,    12,    13,    14,    15,   127,
      17,    52,    46,    20,    21,    59,    23,    18,    21,    28,
      18,   121,    10,    28,    35,     3,    18,    15,    18,    17,
      41,    36,    41,    40,    35,    42,     5,    35,     9,    46,
      70,    71,    34,    50,    34,    14,    15,    50,   166,    18,
     150,    95,    28,    60,    61,   173,    90,    18,    65,     0,
      67,    28,    96,    39,    18,    18,    85,    37,   109,    36,
      36,    40,    60,    34,    34,   105,   106,    84,    85,    67,
      34,    30,    31,    90,   118,    28,    93,    34,   122,    96,
       5,    98,    36,    36,    28,   114,    84,    36,    28,    14,
      15,    28,    36,    18,   111,    35,    20,   114,    35,    28,
     117,   118,    36,   154,   155,   122,   123,   124,    28,     4,
     127,   128,    21,   111,     9,    40,    32,    33,    13,    12,
      13,    36,     4,    18,    22,    23,    24,    25,    26,    27,
      17,   148,     4,   107,   108,    30,    31,     9,    28,    34,
      35,    13,    34,     4,    35,   162,    18,   164,     9,   166,
      35,    35,    13,    34,   171,    38,   173,    18,    30,    31,
      35,    28,    34,    35,    35,    35,    20,    36,    36,    30,
      31,    65,   128,    34,     5,     6,     7,     8,   110,    10,
      11,    12,   148,    14,    15,    16,    72,    18,    19,     5,
       6,     7,     8,     1,    10,    11,    12,    -1,    14,    15,
      16,    -1,    18,     5,     6,     7,     8,    -1,    -1,    -1,
      -1,    -1,    14,    15,    16,    -1,    18
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     3,    43,    47,     9,    76,     0,    36,     5,     6,
       7,     8,    10,    11,    12,    14,    15,    16,    18,    19,
      44,    45,    46,    48,    55,    56,    57,    58,    61,    63,
      64,    65,    66,    67,    68,    81,    48,    49,    50,    54,
      48,    50,    34,    48,    49,    49,    48,    50,    34,    50,
      45,    46,    34,    54,    36,    36,    36,    20,    80,    37,
      28,    34,    48,    53,    48,    34,    53,    28,     4,    13,
      30,    31,    34,    48,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    21,    78,    35,    74,    36,    75,    50,
      35,    48,    52,    28,    17,    79,    35,    52,    39,    59,
      50,    70,    70,    73,    34,    30,    31,    32,    33,    28,
      41,    35,    50,    54,    35,    38,    53,    28,    35,    48,
      75,    53,    35,     5,    14,    15,    40,    48,    60,    62,
      35,    22,    23,    24,    25,    26,    27,    82,    70,    70,
      71,    71,    74,    72,    50,    54,    48,    53,    35,    59,
      53,    48,    51,    48,    34,    34,    51,    40,    62,    35,
      68,    59,    28,    36,    28,    74,    35,    74,    36,    48,
      48,    35,    51,    35,    36,    48,    36,    51,    36,    36
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *bottom, yytype_int16 *top)
#else
static void
yy_stack_print (bottom, top)
    yytype_int16 *bottom;
    yytype_int16 *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule)
#else
static void
yy_reduce_print (yyvsp, yyrule)
    YYSTYPE *yyvsp;
    int yyrule;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      fprintf (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       );
      fprintf (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yymsg, yytype, yyvaluep)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  YYUSE (yyvaluep);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */



/* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;



/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{
  
  int yystate;
  int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;
#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  yytype_int16 yyssa[YYINITDEPTH];
  yytype_int16 *yyss = yyssa;
  yytype_int16 *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  YYSTYPE *yyvsp;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);

#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;


      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     look-ahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to look-ahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 99 "parser.y"
    {
    (yyval.node) = CreateMainProgram2((yyvsp[(1) - (3)].node),(yyvsp[(3) - (3)].node));
    ParseSuccess((yyval.node));
}
    break;

  case 3:
#line 103 "parser.y"
    {
    (yyval.node) = CreateMainProgram3((yyvsp[(1) - (4)].node),(yyvsp[(3) - (4)].node),(yyvsp[(4) - (4)].node));
    ParseSuccess((yyval.node));
}
    break;

  case 4:
#line 111 "parser.y"
    { (yyval.node) = CreateInclude((yyvsp[(2) - (3)].svalue)); }
    break;

  case 5:
#line 117 "parser.y"
    { (yyval.node) = CreateProgram1((yyvsp[(1) - (1)].node)); }
    break;

  case 6:
#line 118 "parser.y"
    { (yyval.node) = CreateProgram2((yyvsp[(1) - (2)].node),(yyvsp[(2) - (2)].node)); }
    break;

  case 7:
#line 125 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 8:
#line 126 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (2)].node); }
    break;

  case 9:
#line 131 "parser.y"
    { (yyval.node) = CreateMagic((yyvsp[(2) - (2)].node)); }
    break;

  case 10:
#line 136 "parser.y"
    { (yyval.node) = CreateId((yyvsp[(1) - (1)].svalue),yylineno); }
    break;

  case 11:
#line 141 "parser.y"
    { (yyval.node) = CreateIndexedId((yyvsp[(1) - (4)].node),(yyvsp[(3) - (4)].node)); }
    break;

  case 12:
#line 147 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 13:
#line 148 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 14:
#line 154 "parser.y"
    { (yyval.node) = CreateIdlist1((yyvsp[(1) - (1)].node)); }
    break;

  case 15:
#line 155 "parser.y"
    { (yyval.node) = CreateIdlist2((yyvsp[(1) - (3)].node),(yyvsp[(3) - (3)].node)); }
    break;

  case 16:
#line 162 "parser.y"
    { (yyval.node) = CreateIdlist1((yyvsp[(1) - (1)].node)); }
    break;

  case 17:
#line 163 "parser.y"
    { (yyval.node) = CreateIdlist2((yyvsp[(1) - (3)].node),(yyvsp[(3) - (3)].node)); }
    break;

  case 18:
#line 169 "parser.y"
    { (yyval.node) = CreateIdlist1((yyvsp[(1) - (1)].node)); }
    break;

  case 19:
#line 170 "parser.y"
    { (yyval.node) = CreateIdlist2((yyvsp[(1) - (3)].node),(yyvsp[(3) - (3)].node)); }
    break;

  case 20:
#line 177 "parser.y"
    { (yyval.node) = CreatePrimaryList1((yyvsp[(1) - (1)].node)); }
    break;

  case 21:
#line 178 "parser.y"
    { (yyval.node) = CreatePrimaryList2((yyvsp[(1) - (3)].node),(yyvsp[(3) - (3)].node)); }
    break;

  case 22:
#line 186 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (2)].node); }
    break;

  case 23:
#line 187 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (2)].node); }
    break;

  case 24:
#line 188 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 25:
#line 194 "parser.y"
    { (yyval.node) = CreateQReg((yyvsp[(2) - (2)].node)); }
    break;

  case 26:
#line 199 "parser.y"
    { (yyval.node) = CreateCReg((yyvsp[(2) - (2)].node)); }
    break;

  case 27:
#line 212 "parser.y"
    { (yyval.node) = CreateGate3((yyvsp[(2) - (4)].node),(yyvsp[(3) - (4)].node),(yyvsp[(4) - (4)].node)); }
    break;

  case 28:
#line 213 "parser.y"
    { (yyval.node) = CreateGate3((yyvsp[(2) - (6)].node),(yyvsp[(5) - (6)].node),(yyvsp[(6) - (6)].node)); }
    break;

  case 29:
#line 214 "parser.y"
    { (yyval.node) = CreateGate4((yyvsp[(2) - (7)].node),(yyvsp[(4) - (7)].node),(yyvsp[(6) - (7)].node),(yyvsp[(7) - (7)].node)); }
    break;

  case 30:
#line 227 "parser.y"
    { (yyval.node) = CreateGateBody1((yyvsp[(2) - (3)].node)); }
    break;

  case 31:
#line 228 "parser.y"
    { (yyval.node) = CreateGateBody0(); }
    break;

  case 32:
#line 237 "parser.y"
    { (yyval.node) = CreateGopList1((yyvsp[(1) - (1)].node)); }
    break;

  case 33:
#line 238 "parser.y"
    { (yyval.node) = CreateGopList2((yyvsp[(1) - (2)].node),(yyvsp[(2) - (2)].node)); }
    break;

  case 34:
#line 254 "parser.y"
    { (yyval.node) = CreateUniversalUnitary((yyvsp[(3) - (5)].node),(yyvsp[(5) - (5)].node)); }
    break;

  case 35:
#line 255 "parser.y"
    { (yyval.node) = CreateCX((yyvsp[(2) - (4)].node),(yyvsp[(4) - (4)].node)); }
    break;

  case 36:
#line 256 "parser.y"
    { (yyval.node) = CreateCustomUnitary2((yyvsp[(1) - (2)].node),(yyvsp[(2) - (2)].node)); }
    break;

  case 37:
#line 257 "parser.y"
    { (yyval.node) = CreateCustomUnitary2((yyvsp[(1) - (4)].node),(yyvsp[(4) - (4)].node)); }
    break;

  case 38:
#line 258 "parser.y"
    { (yyval.node) = CreateCustomUnitary3((yyvsp[(1) - (5)].node),(yyvsp[(3) - (5)].node),(yyvsp[(5) - (5)].node)); }
    break;

  case 39:
#line 271 "parser.y"
    { (yyval.node) = CreateUniversalUnitary((yyvsp[(3) - (6)].node),(yyvsp[(5) - (6)].node)); }
    break;

  case 40:
#line 272 "parser.y"
    { (yyval.node) = CreateCX((yyvsp[(2) - (5)].node),(yyvsp[(4) - (5)].node)); }
    break;

  case 41:
#line 273 "parser.y"
    { (yyval.node) = CreateCustomUnitary2((yyvsp[(1) - (3)].node),(yyvsp[(2) - (3)].node)); }
    break;

  case 42:
#line 274 "parser.y"
    { (yyval.node) = CreateCustomUnitary2((yyvsp[(1) - (5)].node),(yyvsp[(4) - (5)].node)); }
    break;

  case 43:
#line 275 "parser.y"
    { (yyval.node) = CreateCustomUnitary3((yyvsp[(1) - (6)].node),(yyvsp[(3) - (6)].node),(yyvsp[(5) - (6)].node)); }
    break;

  case 44:
#line 276 "parser.y"
    { (yyval.node) = CreateBarrier((yyvsp[(2) - (3)].node)); }
    break;

  case 45:
#line 286 "parser.y"
    { (yyval.node) = CreateOpaque2((yyvsp[(2) - (3)].node),(yyvsp[(3) - (3)].node)); }
    break;

  case 46:
#line 287 "parser.y"
    { (yyval.node) = CreateOpaque2((yyvsp[(2) - (5)].node),(yyvsp[(5) - (5)].node)); }
    break;

  case 47:
#line 288 "parser.y"
    { (yyval.node) = CreateOpaque3((yyvsp[(2) - (6)].node),(yyvsp[(4) - (6)].node),(yyvsp[(6) - (6)].node)); }
    break;

  case 48:
#line 293 "parser.y"
    { (yyval.node) = CreateMeasure((yyvsp[(2) - (4)].node),(yyvsp[(4) - (4)].node)); }
    break;

  case 49:
#line 300 "parser.y"
    { (yyval.node) = CreateBarrier((yyvsp[(2) - (2)].node)); }
    break;

  case 50:
#line 305 "parser.y"
    { (yyval.node) = CreateReset((yyvsp[(2) - (2)].node)); }
    break;

  case 51:
#line 315 "parser.y"
    { (yyval.node) = CreateIf((yyvsp[(3) - (7)].node),(yyvsp[(5) - (7)].node),(yyvsp[(7) - (7)].node)); }
    break;

  case 52:
#line 327 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 53:
#line 328 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 54:
#line 329 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 55:
#line 330 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 56:
#line 331 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 57:
#line 332 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 58:
#line 345 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 59:
#line 346 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 60:
#line 347 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 61:
#line 348 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 62:
#line 349 "parser.y"
    { (yyval.node) = (yyvsp[(2) - (3)].node); }
    break;

  case 63:
#line 350 "parser.y"
    { CreateExternal((yyvsp[(1) - (4)].node),(yyvsp[(3) - (4)].svalue)); }
    break;

  case 64:
#line 356 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 65:
#line 357 "parser.y"
    { (yyval.node) = CreatePrefixOperation("+",(yyvsp[(2) - (2)].node)); }
    break;

  case 66:
#line 358 "parser.y"
    { (yyval.node) = CreatePrefixOperation("-",(yyvsp[(2) - (2)].node)); }
    break;

  case 67:
#line 360 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 68:
#line 361 "parser.y"
    { (yyval.node) = CreateBinaryOperation("+",(yyvsp[(1) - (3)].node),(yyvsp[(3) - (3)].node));  }
    break;

  case 69:
#line 362 "parser.y"
    { (yyval.node) = CreateBinaryOperation("-",(yyvsp[(1) - (3)].node),(yyvsp[(3) - (3)].node));  }
    break;

  case 70:
#line 364 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 71:
#line 365 "parser.y"
    { (yyval.node) = CreateBinaryOperation("*",(yyvsp[(1) - (3)].node),(yyvsp[(3) - (3)].node)); }
    break;

  case 72:
#line 366 "parser.y"
    { (yyval.node) = CreateBinaryOperation("/",(yyvsp[(1) - (3)].node),(yyvsp[(3) - (3)].node)); }
    break;

  case 73:
#line 368 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); }
    break;

  case 74:
#line 369 "parser.y"
    { (yyval.node) = CreateBinaryOperation("^",(yyvsp[(1) - (3)].node),(yyvsp[(3) - (3)].node)); }
    break;

  case 75:
#line 375 "parser.y"
    { (yyval.node) = CreateExpressionList1((yyvsp[(1) - (1)].node));  }
    break;

  case 76:
#line 376 "parser.y"
    { (yyval.node) = CreateExpressionList2((yyvsp[(3) - (3)].node),(yyvsp[(1) - (3)].node)); }
    break;

  case 77:
#line 381 "parser.y"
    { (yyval.node) = CreateInt((yyvsp[(1) - (1)].ivalue)); }
    break;

  case 78:
#line 382 "parser.y"
    { (yyval.node) = CreateReal((yyvsp[(1) - (1)].fvalue)); }
    break;

  case 79:
#line 383 "parser.y"
    { (yyval.node) = CreateRealPI(); }
    break;

  case 80:
#line 385 "parser.y"
    { (yyval.svalue) = (yyvsp[(1) - (1)].svalue); }
    break;

  case 81:
#line 386 "parser.y"
    { (yyval.svalue) = (yyvsp[(1) - (1)].svalue); }
    break;

  case 82:
#line 387 "parser.y"
    { (yyval.svalue) = (yyvsp[(1) - (1)].svalue); }
    break;

  case 83:
#line 388 "parser.y"
    { (yyval.svalue) = (yyvsp[(1) - (1)].svalue); }
    break;

  case 84:
#line 390 "parser.y"
    { (yyval.svalue) = (yyvsp[(1) - (1)].svalue); }
    break;

  case 85:
#line 391 "parser.y"
    { (yyval.svalue) = (yyvsp[(1) - (1)].svalue); }
    break;

  case 86:
#line 392 "parser.y"
    { (yyval.svalue) = (yyvsp[(1) - (1)].svalue); }
    break;

  case 87:
#line 393 "parser.y"
    { (yyval.svalue) = (yyvsp[(1) - (1)].svalue); }
    break;

  case 88:
#line 394 "parser.y"
    { (yyval.svalue) = (yyvsp[(1) - (1)].svalue); }
    break;

  case 89:
#line 395 "parser.y"
    { (yyval.svalue) = (yyvsp[(1) - (1)].svalue); }
    break;


/* Line 1267 of yacc.c.  */
#line 1988 "y.tab.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;


  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (yymsg);
	  }
	else
	  {
	    yyerror (YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}


#line 398 "parser.y"


#pragma clang diagnostic pop


