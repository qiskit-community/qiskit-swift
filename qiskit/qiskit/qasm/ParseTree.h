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


#import <Foundation/Foundation.h>

@class Node;

extern int yylineno;

typedef struct yy_buffer_state *YY_BUFFER_STATE;
YY_BUFFER_STATE  yy_scan_string(const char *s);

typedef unsigned long StringIdType;
typedef unsigned long NodeIdType;

int yyparse(void);

extern void (^ParseSuccessBlock)(NSObject *node);
extern void (^ParseFailBlock)(int line, const char *msg);

@interface ParseTree : NSObject

+(void)success: (NodeIdType) mainProgram;
+(void)fail: (int) line msg: (const char*) msg;
+(const char*) getIncludePath: (const char*) path;
+(void)  clearState;
+(StringIdType) addString: (const char*) str;
+(NodeIdType) createBarrier: (NodeIdType) primarylist;
+(NodeIdType) createBinaryOperation: (const char*) op operand1: (NodeIdType) o1 operand2: (NodeIdType) o2;
+(NodeIdType) createCX: (NodeIdType) arg1 arg2: (NodeIdType) arg2;
+(NodeIdType) createCReg: (NodeIdType) indexed_id;
+(NodeIdType) createCustomUnitary: (NodeIdType) identifier bitlist: (NodeIdType) bitlist;
+(NodeIdType) createCustomUnitary: (NodeIdType) identifier arguments: (NodeIdType) args bitlist: (NodeIdType) bitlist;
+(NodeIdType) createExpressionList: (NodeIdType) exp;
+(NodeIdType) createExpressionList: (NodeIdType) elist expression: (NodeIdType) exp;
+(NodeIdType) createExternal: (NodeIdType) identifier external: (StringIdType) external;
+(NodeIdType) createGate: (NodeIdType) identifier list2: (NodeIdType) list2 list3: (NodeIdType) list3;
+(NodeIdType) createGate: (NodeIdType) identifier list1: (NodeIdType) list1 list2: (NodeIdType) list2 list3: (NodeIdType) list3;
+(NodeIdType) createGateBody;
+(NodeIdType) createGateBodyWithList: (NodeIdType) goplist;
+(NodeIdType) createGopList:(NodeIdType) gop;
+(NodeIdType) createGopList: (NodeIdType)goplist gate_op:(NodeIdType) gop;
+(NodeIdType) createId: (StringIdType) identifer line: (int) line;
+(NodeIdType) createIdlist: (NodeIdType) identifier;
+(NodeIdType) createIdlist: (NodeIdType) idlist identifier: (NodeIdType) identifier;
+(NodeIdType) createIf: (NodeIdType) identifier nninteger: (NodeIdType) integer quantum_op: (NodeIdType) qop;
+(NodeIdType) createInclude: (StringIdType) file;
+(NodeIdType) createIndexedId: (NodeIdType) identifier index: (NodeIdType) nninteger;
+(NodeIdType) createInt: (int) integer;
+(NodeIdType) createMagic: (NodeIdType) real;
+(NodeIdType) createMainProgram: (NodeIdType) magic program: (NodeIdType) program;
+(NodeIdType) createMainProgram: (NodeIdType) magic include: (NodeIdType) incld program: (NodeIdType) program;
+(NodeIdType) createMeasure: (NodeIdType) argument1 argument: (NodeIdType) argument2;
+(NodeIdType) createOpaque: (NodeIdType) identifier list1: (NodeIdType) list1;
+(NodeIdType) createOpaque: (NodeIdType) identifier list1: (NodeIdType) list1 list2: (NodeIdType) list2;
+(NodeIdType) createPrefixOperation: (const char*) op operand: (NodeIdType) o;
+(NodeIdType) createPrimaryList: (NodeIdType) primary;
+(NodeIdType) createPrimaryList: (NodeIdType) list primary: (NodeIdType) primary;
+(NodeIdType) createProgram: (NodeIdType) statement;
+(NodeIdType) createProgram: (NodeIdType) program statement: (NodeIdType) statement;
+(NodeIdType) createQReg: (NodeIdType) indexed_id;
+(NodeIdType) createReal: (double) real;
+(NodeIdType) createReset: (NodeIdType) identifier;
+(NodeIdType) createUniversalUnitary: (NodeIdType) list1 list2: (NodeIdType) list2;

@end
