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

+(Node*) createUniversalUnitary: (Node*) o1 object2: (Node*) o2 object3: (Node*) o3 {
    NodeUniversalUnitary *node = [[NodeUniversalUnitary alloc] initWithObject1:o1 object2:o2 object3:o3];
    return node;   
}

+(Node*) createAnylistNode: (Node*) list {
    NodeAnyList *node = [[NodeAnyList alloc] initWithList:list];
    return node;
}

+(Node*) createIdlistNode: (Node*) i0 identifier: (Node*) identifier {
    NodeIdList *node = [[NodeIdList alloc] initWithIdList:i0 identifier:identifier];
    return node;
}

+(Node*) createMixedlistNode: (Node*) i0 item2: (Node*) i1 item3: (Node*) i2 {
    NodeMixedList *node = [[NodeMixedList alloc] initWithItem1:i0 item2:i1 item3:i2];
    return node;
}

+(Node*) createArgumentNode: (Node*) identifier parameter: (Node*) nninteger {
    NodeArgument *node = [[NodeArgument alloc] initWithIdentifier:identifier parameter:nninteger];
    return node;
}

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

+(Node*) createMeasureNode {
    NodeMeasure *node =  [[NodeMeasure alloc] init];
    return node;
}

+(Node*) createResetNode {
    NodeReset *node =  [[NodeReset alloc] init];
    return node;
}

@end
