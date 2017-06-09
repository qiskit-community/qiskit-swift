//
//  ParserTree.h
//  qiskit
//
//  Created by Joe Ligman on 5/22/17.
//  Copyright © 2017 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SymbolTable.h"

@class Node;

@interface ParseTree : NSObject

+(Node*) createMainProgram: (Node*) magic version: (Node*) version include: (Node*) incld program: (Node*) program;
+(Node*) createProgramNode: (Node*) program statement: (Node*) statement;
+(Node*) createIncludeNode: (NSString*) file;
+(Node*) createStatmentNode: (Node*) p1 p2: (Node*) p2 p3: (Node*) p3 p4: (Node*) p4;
+(Node*) createDeclNode: (Node*) reg identifier: (Node*) ident nninteger: (Node*) nninteger;
+(Node*) createGateDeclNode: (Node*) gate identifier: (Node*) ident idlist1: (Node*) idlist1 idlist2: (Node*) idlist2;
+(Node*) createGoplistNode: (Node*) barrier uop: (Node*) uop idlist: (Node*) idlist goplist: (Node*) goplist;
+(Node*) createUniversalUnitary: (Node*) o1 object2: (Node*) o2 object3: (Node*) o3;
+(Node*) createAnylistNode: (Node*) list;
+(Node*) createIdlistNode: (Node*) i0 identifier: (Node*) identifier;
+(Node*) createMixedlistNode: (Node*) i0 item2: (Node*) i1 item3: (Node*) i2;
+(Node*) createArgumentNode: (Node*) identifier parameter: (Node*) nninteger;
+(Node*) createExpressionList: (Node*) exp1 expression: (Node*) exp2;
+(Node*) createBinaryOperation: (NSString*) op operand1: (Node*) o1 operand2: (Node*) o2;
+(Node*) createPrefixOperation: (NSString*) op operand: (Node*) o;
+(Node*) createIdNodeWithValue: (NSString*) value;
+(Node*) createIntNodeWithValue: (int) value;
+(Node*) createRealNodeWithValue: (float) value;
+(Node*) createBarrierNode;
+(Node*) createGateNode;
+(Node*) createCRegNode;
+(Node*) createQRegNode;
+(Node*) createIfNode;
+(Node*) createMagicNode;
+(Node*) createMeasureNode;
+(Node*) createOpaqueNode;
+(Node*) createResetNode;
    
@end
