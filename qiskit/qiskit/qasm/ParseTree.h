//
//  ParserTree.h
//  qiskit
//
//  Created by Joe Ligman on 5/22/17.
//  Copyright © 2017 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Node;
@class SymbolTable;

@interface ParseTree : NSObject

+(Node*) createMainProgram: (Node*) magic include: (Node*) incld program: (Node*) program;
+(Node*) createProgram: (Node*) program statement: (Node*) statement;
+(Node*) createInclude: (NSString*) file;
+(Node*) createInt: (int) integer;
+(Node*) createReal: (float) real;
+(Node*) createMagic: (Node*) real;
+(Node*) createId: (NSString*) identifer line: (int) line;
+(Node*) createIdlist: (Node*) idlist identifier: (Node*) identifier;
+(Node*) createPrimaryList: (Node*) list primary: (Node*) primary;
+(Node*) createQReg: (Node*) indexed_id;
+(Node*) createCReg: (Node*) indexed_id;
+(Node*) createGate: (Node*) identifier list1: (Node*) list1 list2: (Node*) list2 list3: (Node*) list3;
+(Node*) createGateBody: (Node*) goplist;
+(Node*) createGateOpList: (Node*) goplist gate_op: (Node*) gop;
+(Node*) createCustomUnitary: (Node*) identifier list: (Node*) list list2: (Node*) list2;
+(Node*) createCX: (Node*) arg1 arg2: (Node*) arg2;
+(Node*) createUniversalUnitary: (Node*) list1 list2: (Node*) list2;
+(Node*) createOpaque: (Node*) identifier list1: (Node*) list1 list2: (Node*) list2;
+(Node*) createMeasure: (Node*) argument1 argument: (Node*) argument2;
+(Node*) createBarrier: (Node*) primarylist;
+(Node*) createReset: (Node*) identifier;
+(Node*) createIf: (Node*) identifier nninteger: (Node*) integer quantum_op: (Node*) qop;
+(Node*) createIndexedId: (Node*) identifier index: (Node*) nninteger;
+(Node*) createExternal: (Node*) identifier external: (NSString*) external;
+(Node*) createPrefixOperation: (NSString*) op operand: (Node*) o;
+(Node*) createBinaryOperation: (NSString*) op operand1: (Node*) o1 operand2: (Node*) o2;
+(Node*) createExpressionList: (Node*) elist expression: (Node*) exp;

+(SymbolTable*) symbolTable;
@end
