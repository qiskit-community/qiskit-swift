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

@interface ParseTree : NSObject

+(void)clearNodes;
+(Node*) createBarrier: (Node*) primarylist;
+(Node*) createBinaryOperation: (NSString*) op operand1: (Node*) o1 operand2: (Node*) o2;
+(Node*) createCX: (Node*) arg1 arg2: (Node*) arg2;
+(Node*) createCReg: (Node*) indexed_id;
+(Node*) createCustomUnitary: (Node*) identifier arguments: (Node*) args bitlist: (Node*) bitlist;
+(Node*) createExpressionList: (Node*) elist expression: (Node*) exp;
+(Node*) createExternal: (Node*) identifier external: (NSString*) external;
+(Node*) createGate: (Node*) identifier list1: (Node*) list1 list2: (Node*) list2 list3: (Node*) list3;
+(Node*) createGateBody: (Node*) goplist;
+(Node*) createGopList: (Node*)goplist gate_op:(Node*) gop;
+(Node*) createId: (NSString*) identifer line: (int) line;
+(Node*) createIdlist: (Node*) idlist identifier: (Node*) identifier;
+(Node*) createIf: (Node*) identifier nninteger: (Node*) integer quantum_op: (Node*) qop;
+(Node*) createInclude: (NSString*) file;
+(Node*) createIndexedId: (Node*) identifier index: (Node*) nninteger;
+(Node*) createInt: (int) integer;
+(Node*) createMagic: (Node*) real;
+(Node*) createMainProgram: (Node*) magic include: (Node*) incld program: (Node*) program;
+(Node*) createMeasure: (Node*) argument1 argument: (Node*) argument2;
+(Node*) createOpaque: (Node*) identifier list1: (Node*) list1 list2: (Node*) list2;
+(Node*) createPrefixOperation: (NSString*) op operand: (Node*) o;
+(Node*) createPrimaryList: (Node*) list primary: (Node*) primary;
+(Node*) createProgram: (Node*) program statement: (Node*) statement;
+(Node*) createQReg: (Node*) indexed_id;
+(Node*) createReal: (double) real;
+(Node*) createReset: (Node*) identifier;
+(Node*) createUniversalUnitary: (Node*) list1 list2: (Node*) list2;

@end
