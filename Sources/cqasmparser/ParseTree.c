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

#include "ParseTree.h"

void (*ParseSuccess)(NodeIdType);
void (*ParseFail)(int,const char*);
long (*GetIncludeContents)(const char*,char*,long);
StringIdType (*AddString)(const char*);
NodeIdType (*CreateBarrier)(NodeIdType);
NodeIdType (*CreateBinaryOperation)(const char*,NodeIdType,NodeIdType);
NodeIdType (*CreateCX)(NodeIdType,NodeIdType);
NodeIdType (*CreateCReg)(NodeIdType);
NodeIdType (*CreateCustomUnitary2)(NodeIdType,NodeIdType);
NodeIdType (*CreateCustomUnitary3)(NodeIdType,NodeIdType,NodeIdType);
NodeIdType (*CreateExpressionList1)(NodeIdType);
NodeIdType (*CreateExpressionList2)(NodeIdType,NodeIdType);
NodeIdType (*CreateExternal)(NodeIdType,StringIdType);
NodeIdType (*CreateGate3)(NodeIdType,NodeIdType,NodeIdType);
NodeIdType (*CreateGate4)(NodeIdType,NodeIdType,NodeIdType,NodeIdType);
NodeIdType (*CreateGateBody0)(void);
NodeIdType (*CreateGateBody1)(NodeIdType);
NodeIdType (*CreateGopList1)(NodeIdType);
NodeIdType (*CreateGopList2)(NodeIdType,NodeIdType);
NodeIdType (*CreateId)(StringIdType,long);
NodeIdType (*CreateIdlist1)(NodeIdType);
NodeIdType (*CreateIdlist2)(NodeIdType,NodeIdType);
NodeIdType (*CreateIf)(NodeIdType,NodeIdType,NodeIdType);
NodeIdType (*CreateInclude)(StringIdType);
NodeIdType (*CreateIndexedId)(NodeIdType,NodeIdType);
NodeIdType (*CreateInt)(long);
NodeIdType (*CreateMagic)(NodeIdType);
NodeIdType (*CreateMainProgram2)(NodeIdType,NodeIdType);
NodeIdType (*CreateMainProgram3)(NodeIdType,NodeIdType,NodeIdType);
NodeIdType (*CreateMeasure)(NodeIdType,NodeIdType);
NodeIdType (*CreateOpaque2)(NodeIdType,NodeIdType);
NodeIdType (*CreateOpaque3)(NodeIdType,NodeIdType,NodeIdType);
NodeIdType (*CreatePrefixOperation)(const char*,NodeIdType);
NodeIdType (*CreatePrimaryList1)(NodeIdType);
NodeIdType (*CreatePrimaryList2)(NodeIdType,NodeIdType);
NodeIdType (*CreateProgram1)(NodeIdType);
NodeIdType (*CreateProgram2)(NodeIdType,NodeIdType);
NodeIdType (*CreateQReg)(NodeIdType);
NodeIdType (*CreateReal)(double);
NodeIdType (*CreateRealPI)(void);
NodeIdType (*CreateReset)(NodeIdType);
NodeIdType (*CreateUniversalUnitary)(NodeIdType,NodeIdType);
