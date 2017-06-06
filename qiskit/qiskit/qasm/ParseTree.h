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

+(Node*) createExpressionList: (Node*) exp1 expression: (Node*) exp2;
+(Node*) createBinaryOperation: (NSString*) op operand1: (Node*) o1 operand2: (Node*) o2;
+(Node*) createPrefixOperation: (NSString*) op operand: (Node*) o;
+(Node*) createIdNodeWithValue: (NSString*) value;
+(Node*) createIntNodeWithValue: (int) value;
+(Node*) createRealNodeWithValue: (float) value;
+(Node*) createUniversalUnitary;
    
@end
