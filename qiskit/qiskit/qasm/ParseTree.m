//
//  ParserTree.m
//  qiskit
//
//  Created by Joe Ligman on 5/22/17.
//  Copyright © 2017 IBM. All rights reserved.
//

#import "ParseTree.h"


@implementation Node
@synthesize nodeType = _nodeType;
@synthesize leftOperand = _leftOperand;
@synthesize rightOperand = _rightOperand;
@end

@implementation NodeRelational
@synthesize roperator = _roperator;
@end

@implementation NodeEquality: Node
@synthesize eoperator = _eoperator;
@end

@implementation NodeSymbolRef: Node
@synthesize symbol = _symbol;
@end

@implementation NodeIf: Node
@synthesize if_branch = _if_branch;
@end

@implementation NodeAssignment: Node
@synthesize symbol = _symbol;
@synthesize value = _value;
@end

@implementation NodeReal: Node
@synthesize real = _real;
@end

@implementation NodeNNInteger: Node
@synthesize nnInteger = _nnInteger;
@end


@implementation ParseTree

+(Node*) createNode: (int) nodeType left: (Node*) leftOperand right: (Node*) rightOperand {
    Node *node = [[Node alloc] init];
    node.nodeType = nodeType;
    node.leftOperand = leftOperand;
    node.rightOperand = rightOperand;
    return node;
}

+(NodeRelational*) createRelationalNode: (RelationalOperator) relationalOperator left: (Node*) leftOperand right: (Node*) rightOperand {
    NodeRelational *node = [[NodeRelational alloc] init];
    node.nodeType = 'R';
    node.leftOperand = leftOperand;
    node.rightOperand = rightOperand;
    return node;
}

+(NodeEquality*) createEqualityNode: (EqualityOperator) equalityOperator left: (Node*) leftOperand right: (Node*) rightOperand {
    NodeEquality *node = [[NodeEquality alloc] init];
    node.nodeType = 'E';
    node.leftOperand = leftOperand;
    node.rightOperand = rightOperand;
    return node;
}

+(NodeSymbolRef*) createSymbolRefNode: (SymbolObject *) symbol {
    NodeSymbolRef *node = [[NodeSymbolRef alloc] init];
    node.nodeType = 'S';
    node.symbol = symbol;
    return node;
}

+(NodeIf*) createIfNode: (Node *) branch {
    NodeIf *node = [[NodeIf alloc] init];
    node.nodeType = 'I';
    node.if_branch = branch;
    return node;
}

+(NodeAssignment*) createAssigmentNode:(SymbolObject *) symbol withObject: (Node*) value {
    NodeAssignment *node = [[NodeAssignment alloc] init];
    node.nodeType = 'A';
    node.symbol = symbol;
    node.value = value;
    return node;
}

+(NodeReal*) createRealNodeWithValue: (float) value {
    NodeReal *node = [[NodeReal alloc] init];
    node.nodeType = 'R';
    node.real = value;
    return node;
}

+(NodeNNInteger*) createNNIntegerNodeWithValue: (int) value {
    NodeNNInteger *node = [[NodeNNInteger alloc] init];
    node.nodeType = 'N';
    node.nnInteger = value;
    return node;
}

@end
