// Copyright 2017 IBM RESEARCH. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

#ifndef ParseTree_h
#define ParseTree_h

#include <math.h>

extern int yylineno;

typedef struct yy_buffer_state *YY_BUFFER_STATE;
YY_BUFFER_STATE  yy_scan_string(const char *s);

typedef long StringIdType;
typedef long NodeIdType;

extern int yyparse(void);

extern void (*ParseSuccess)(NodeIdType);
extern void (*ParseFail)(int,const char*);
extern const char* (*GetIncludeContents)(const char*);
extern StringIdType (*AddString)(const char*);
extern NodeIdType (*CreateBarrier)(NodeIdType);
extern NodeIdType (*CreateBinaryOperation)(const char*,NodeIdType,NodeIdType);
extern NodeIdType (*CreateCX)(NodeIdType,NodeIdType);
extern NodeIdType (*CreateCReg)(NodeIdType);
extern NodeIdType (*CreateCustomUnitary2)(NodeIdType,NodeIdType);
extern NodeIdType (*CreateCustomUnitary3)(NodeIdType,NodeIdType,NodeIdType);
extern NodeIdType (*CreateExpressionList1)(NodeIdType);
extern NodeIdType (*CreateExpressionList2)(NodeIdType,NodeIdType);
extern NodeIdType (*CreateExternal)(NodeIdType,StringIdType);
extern NodeIdType (*CreateGate3)(NodeIdType,NodeIdType,NodeIdType);
extern NodeIdType (*CreateGate4)(NodeIdType,NodeIdType,NodeIdType,NodeIdType);
extern NodeIdType (*CreateGateBody0)(void);
extern NodeIdType (*CreateGateBody1)(NodeIdType);
extern NodeIdType (*CreateGopList1)(NodeIdType);
extern NodeIdType (*CreateGopList2)(NodeIdType,NodeIdType);
extern NodeIdType (*CreateId)(StringIdType,long);
extern NodeIdType (*CreateIdlist1)(NodeIdType);
extern NodeIdType (*CreateIdlist2)(NodeIdType,NodeIdType);
extern NodeIdType (*CreateIf)(NodeIdType,NodeIdType,NodeIdType);
extern NodeIdType (*CreateInclude)(StringIdType);
extern NodeIdType (*CreateIndexedId)(NodeIdType,NodeIdType);
extern NodeIdType (*CreateInt)(long);
extern NodeIdType (*CreateMagic)(NodeIdType);
extern NodeIdType (*CreateMainProgram2)(NodeIdType,NodeIdType);
extern NodeIdType (*CreateMainProgram3)(NodeIdType,NodeIdType,NodeIdType);
extern NodeIdType (*CreateMeasure)(NodeIdType,NodeIdType);
extern NodeIdType (*CreateOpaque2)(NodeIdType,NodeIdType);
extern NodeIdType (*CreateOpaque3)(NodeIdType,NodeIdType,NodeIdType);
extern NodeIdType (*CreatePrefixOperation)(const char*,NodeIdType);
extern NodeIdType (*CreatePrimaryList1)(NodeIdType);
extern NodeIdType (*CreatePrimaryList2)(NodeIdType,NodeIdType);
extern NodeIdType (*CreateProgram1)(NodeIdType);
extern NodeIdType (*CreateProgram2)(NodeIdType,NodeIdType);
extern NodeIdType (*CreateQReg)(NodeIdType);
extern NodeIdType (*CreateReal)(double);
extern NodeIdType (*CreateReset)(NodeIdType);
extern NodeIdType (*CreateUniversalUnitary)(NodeIdType,NodeIdType);

#endif
