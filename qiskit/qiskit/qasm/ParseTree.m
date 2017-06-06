//
//  ParserTree.m
//  qiskit
//
//  Created by Joe Ligman on 5/22/17.
//  Copyright © 2017 IBM. All rights reserved.
//

#import "ParseTree.h"
#import <qiskit/qiskit-Swift.h>


@implementation ParseTree

+(Node*) createExpressionList: (Node*) exp1 expression: (Node*) exp2 {
    NodeExpressionList *node = [[NodeExpressionList alloc] initWithChildren: @[exp1, exp2]];
    return node;
}
    
+(Node*) createBinaryOperation: (NSString*) op operand1: (Node*) o1 operand2: (Node*) o2 {
    NodeBinaryOp *node = [[NodeBinaryOp alloc] initWithOp:op children: @[o1, o2]];
    return node;
}
    
+(Node*) createPrefixOperation: (NSString*) op operand: (Node*) o {
    NodePrefix *node = [[NodePrefix alloc] initWithOp:op children: @[o]];
    return node;
}

+(Node*) createIdNodeWithValue: (NSString*) value {
    NodeId *node = [[NodeId alloc] initWithName: value];
    return node;
}

+(Node*) createIntNodeWithValue: (int) value {
    NodeNNInt *node = [[NodeNNInt alloc] initWithValue: value];
    return node;
}

+(Node*) createRealNodeWithValue: (float) value {
    NodeReal *node = [[NodeReal alloc] initWithId: value];
    return node;
}

+(Node*) createUniversalUnitary {
    NodeUniversalUnitary *node = [[NodeUniversalUnitary alloc] init];
    return node;
}


@end
