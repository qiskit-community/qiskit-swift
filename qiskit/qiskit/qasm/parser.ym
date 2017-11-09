%{

#include "ParseTree.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"

int yylex(void);
void yyerror(char *s);

%}

%union {
    int ivalue;
    double fvalue;
    long svalue;
    long node;
}

%token <svalue> OPENQASM
%token <ivalue> NNINTEGER
%token <svalue> BARRIER
%token <svalue> OPAQUE
%token <svalue> RESET
%token <svalue> IF
%token <fvalue> REAL
%token <svalue> QREG
%token <svalue> CREG
%token <svalue> GATE
%token <svalue> PI
%token <svalue> CX
%token <svalue> U
%token <svalue> MEASURE
%token <svalue> MATCHES
%token <svalue> ID
%token <svalue> INCLD
%token <svalue> STRING
%token <svalue> ASSIGN

%token <svalue> SIN
%token <svalue> COS
%token <svalue> TAN
%token <svalue> EXP
%token <svalue> LN
%token <svalue> SQRT

%type <node> mainprogram
%type <node> include
%type <node> program
%type <node> statement
%type <node> magic
%type <node> id
%type <node> indexed_id
%type <node> primary
%type <node> id_list
%type <node> gate_id_list
%type <node> bit_list
%type <node> primary_list
%type <node> decl
%type <node> qreg_decl
%type <node> creg_decl
%type <node> gate_decl
%type <node> gate_body
%type <node> gate_op_list
%type <node> unitary_op
%type <node> gate_op
%type <node> opaque
%type <node> measure
%type <node> barrier
%type <node> reset
%type <node> ifn
%type <node> quantum_op
%type <node> unary
%type <node> prefix_expression
%type <node> additive_expression
%type <node> multiplicative_expression
%type <node> expression
%type <node> exp_list
%type <node> nninteger
%type <node> real
%type <node> pi
%type <svalue> assign
%type <svalue> matches
%type <svalue> incld
%type <svalue> external
%type <svalue> string


%left ','
%right '='
%left '+' '-'
%left '*' '/'
%left '(' ')'

%%

// ----------------------------------------
// mainprogram : magic ';' program
// ----------------------------------------
mainprogram : magic ';' program {
    $$ = CreateMainProgram2($1,$3);
    ParseSuccess($$);
}
| magic ';' include program {
    $$ = CreateMainProgram3($1,$3,$4);
    ParseSuccess($$);
}

// ----------------------------------------
// include : include file
// ----------------------------------------
include : incld string ';' { $$ = CreateInclude($2); }

// ----------------------------------------
//  program : statement
//          | program statement
// ----------------------------------------
program : statement { $$ = CreateProgram1($1); }
| program statement { $$ = CreateProgram2($1,$2); }

// ----------------------------------------
//  statement : decl
//            | quantum_op ';'
//            | magic ';'
// ----------------------------------------
statement : decl { $$ = $1; }
| quantum_op ';' { $$ = $1; }

// ----------------------------------------
// magic : MAGIC REAL
// ----------------------------------------
magic : OPENQASM real { $$ = CreateMagic($2); }

// ----------------------------------------
//  id : ID
// ----------------------------------------
id : ID { $$ = CreateId($1,yylineno); }

// ----------------------------------------
//  indexed_id : ID [ int ]
// ----------------------------------------
indexed_id : id '[' nninteger ']' { $$ = CreateIndexedId($1,$3); }

// ----------------------------------------
//  primary : id
//          | indexed_id
// ----------------------------------------
primary : id { $$ = $1; }
| indexed_id { $$ = $1; }

// ----------------------------------------
//  id_list : id
//          | id_list ',' id
// ----------------------------------------
id_list : id { $$ = CreateIdlist1($1); }
| id_list ',' id { $$ = CreateIdlist2($1,$3); }


// ----------------------------------------
//  gate_id_list : id
//               | gate_id_list ',' id
// ----------------------------------------
gate_id_list : id { $$ = CreateIdlist1($1); }
| gate_id_list ',' id { $$ = CreateIdlist2($1,$3); }

// ----------------------------------------
//  bit_list : bit
//           | bit_list ',' bit
// ----------------------------------------
bit_list : id { $$ = CreateIdlist1($1); }
| bit_list ',' id { $$ = CreateIdlist2($1,$3); }


// ----------------------------------------
//  primary_list : primary
//               | primary_list ',' primary
// ----------------------------------------
primary_list : primary { $$ = CreatePrimaryList1($1); }
| primary_list ',' primary  { $$ = CreatePrimaryList2($1,$3); }


// ----------------------------------------
//  decl : qreg_decl
//       | creg_decl
//       | gate_decl
// ----------------------------------------
decl : qreg_decl ';' { $$ = $1; }
| creg_decl ';' { $$ = $1; }
| gate_decl { $$ = $1; }


// ----------------------------------------
//  qreg_decl : QREG indexed_id
// ----------------------------------------
qreg_decl : QREG indexed_id { $$ = CreateQReg($2); }

// ----------------------------------------
//  creg_decl : QREG indexed_id
// ----------------------------------------
creg_decl : CREG indexed_id { $$ = CreateCReg($2); }


// Gate_body will throw if there are errors, so we don't need to cover
// that here. Same with the id_lists - if they are not legal, we die
// before we get here
//
// ----------------------------------------
//  gate_decl : GATE id gate_scope                      bit_list gate_body
//            | GATE id gate_scope '(' ')'              bit_list gate_body
//            | GATE id gate_scope '(' gate_id_list ')' bit_list gate_body
//
// ----------------------------------------
gate_decl : GATE id bit_list gate_body { $$ = CreateGate3($2,$3,$4); }
| GATE id '(' ')' bit_list gate_body  { $$ = CreateGate3($2,$5,$6); }
| GATE id '(' gate_id_list ')' bit_list gate_body { $$ = CreateGate4($2,$4,$6,$7); }


// ----------------------------------------
//  gate_body : '{' gate_op_list '}'
//            | '{' '}'
//
//            | '{' gate_op_list error
//            | '{' error
//
// Error handling: gete_op will throw if there's a problem so we won't
//                 get here with in the gate_op_list
// ----------------------------------------
gate_body : '{' gate_op_list '}' { $$ = CreateGateBody1($2); }
| '{' '}' { $$ = CreateGateBody0(); }

// ----------------------------------------
//  gate_op_list : gate_op
//               | gate_op_ist gate_op
//
// Error handling: gete_op will throw if there's a problem so we won't
//                 get here with errors
// ----------------------------------------
gate_op_list : gate_op { $$ = CreateGopList1($1); }
| gate_op_list gate_op { $$ = CreateGopList2($1,$2); }


// ----------------------------------------
// These are for use outside of gate_bodies and allow
// indexed ids everywhere.
//
// unitary_op : U '(' exp_list ')'  primary
//            | CX                  primary ',' primary
//            | id                  pirmary_list
//            | id '(' ')'          primary_list
//            | id '(' exp_list ')' primary_list
//
// Note that it might not be unitary - this is the mechanism that
// is also used to invoke calls to 'opaque'
// ----------------------------------------
unitary_op : U '(' exp_list ')'  primary  { $$ = CreateUniversalUnitary($3,$5); }
| CX primary ',' primary { $$ = CreateCX($2,$4); }
| id primary_list { $$ = CreateCustomUnitary2($1,$2); }
| id '(' ')' primary_list { $$ = CreateCustomUnitary2($1,$4); }
| id '(' exp_list ')' primary_list { $$ = CreateCustomUnitary3($1,$3,$5); }

// ----------------------------------------
// This is a restricted set of "quantum_op" which also
// prohibits indexed ids, for use in a gate_body
//
// gate_op : U '(' exp_list ')'  id         ';'
//         | CX                  id ',' id  ';'
//         | id                  id_list    ';'
//         | id '(' ')'          id_list    ';'
//         | id '(' exp_list ')' id_list    ';'
//         | BARRIER id_list                ';'
// ----------------------------------------
gate_op : U '(' exp_list ')' id ';' { $$ = CreateUniversalUnitary($3,$5); }
| CX id ',' id  ';' { $$ = CreateCX($2,$4); }
| id id_list ';' { $$ = CreateCustomUnitary2($1,$2); }
| id '(' ')' id_list ';' { $$ = CreateCustomUnitary2($1,$4); }
| id '(' exp_list ')' id_list ';' { $$ = CreateCustomUnitary3($1,$3,$5); }
| BARRIER id_list ';' { $$ = CreateBarrier($2); }


// ----------------------------------------
// opaque : OPAQUE id gate_scope                      bit_list
//        | OPAQUE id gate_scope '(' ')'              bit_list
//        | OPAQUE id gate_scope '(' gate_id_list ')' bit_list
//
// These are like gate declaratons only wihtout a body.
// ----------------------------------------
opaque : OPAQUE id bit_list { $$ = CreateOpaque2($2,$3); }
| OPAQUE id '(' ')' bit_list { $$ = CreateOpaque2($2,$5); }
| OPAQUE id '(' gate_id_list ')' bit_list { $$ = CreateOpaque3($2,$4,$6); }

// ----------------------------------------
// measure : MEASURE primary ASSIGN primary
// ----------------------------------------
measure : MEASURE primary assign primary { $$ = CreateMeasure($2,$4); }

// ----------------------------------------
// barrier : BARRIER primary_list
//
// Errors are covered by handling erros in primary_list
// ----------------------------------------
barrier : BARRIER primary_list { $$ = CreateBarrier($2); }

// ----------------------------------------
// reset : RESET primary
// ----------------------------------------
reset : RESET primary { $$ = CreateReset($2); }

// ----------------------------------------
// IF '(' ID MATCHES NNINTEGER ')' quantum_op
// if : IF '(' id MATCHES NNINTEGER ')' quantum_op
// if : IF '(' id error
// if : IF '(' id MATCHES error
// if : IF '(' id MATCHES NNINTEGER error
// if : IF error
// ----------------------------------------
ifn : IF '(' id matches nninteger ')' quantum_op { $$ = CreateIf($3,$5,$7); }

// ----------------------------------------
// These are all the things you can have outside of a gate declaration
//        quantum_op : unitary_op
//                   | opaque
//                   | measure
//                   | reset
//                   | barrier
//                   | if
//
// ----------------------------------------
quantum_op : unitary_op { $$ = $1; }
| opaque { $$ = $1; }
| measure { $$ = $1; }
| barrier { $$ = $1; }
| reset { $$ = $1; }
| ifn { $$ = $1; }


// ----------------------------------------
// unary : NNINTEGER
//       | REAL
//       | PI
//       | ID
//       | '(' expression ')'
//       | id '(' expression ')'
//
// We will trust 'expression' to throw before we have to handle it here
// ----------------------------------------
unary : nninteger { $$ = $1; }
| real { $$ = $1; }
| pi { $$ = $1; }
| id { $$ = $1; }
| '(' expression ')' { $$ = $2; }
| id '(' external ')' { CreateExternal($1,$3); }


// ----------------------------------------
// Prefix
// ----------------------------------------
prefix_expression : unary { $$ = $1; }
| '+' prefix_expression { $$ = CreatePrefixOperation("+",$2); }
| '-' prefix_expression { $$ = CreatePrefixOperation("-",$2); }

additive_expression : prefix_expression { $$ = $1; }
| additive_expression '+' prefix_expression { $$ = CreateBinaryOperation("+",$1,$3);  }
| additive_expression '-' prefix_expression { $$ = CreateBinaryOperation("-",$1,$3);  }

multiplicative_expression : additive_expression { $$ = $1; }
| multiplicative_expression '*' additive_expression { $$ = CreateBinaryOperation("*",$1,$3); }
| multiplicative_expression '/' additive_expression { $$ = CreateBinaryOperation("/",$1,$3); }

expression : multiplicative_expression { $$ = $1; }
| expression '^' multiplicative_expression { $$ = CreateBinaryOperation("^",$1,$3); }

// ----------------------------------------
// exp_list : exp
//          | exp_list ',' exp
// ----------------------------------------
exp_list : expression { $$ = CreateExpressionList1($1);  }
| expression ',' exp_list { $$ = CreateExpressionList2($3,$1); }

// ----------------------------------------
// Terminals
// ----------------------------------------
nninteger : NNINTEGER { $$ = CreateInt($1); }
real : REAL { $$ = CreateReal($1); }
pi : PI { $$ = CreateReal(M_PI); }

assign : ASSIGN { $$ = $1; }
matches : MATCHES { $$ = $1; }
string : STRING { $$ = $1; }
incld : INCLD { $$ = $1; }

external : SIN { $$ = $1; }
| COS { $$ = $1; }
| TAN { $$ = $1; }
| EXP { $$ = $1; }
| LN { $$ = $1; }
| SQRT { $$ = $1; }


%%

#pragma clang diagnostic pop

