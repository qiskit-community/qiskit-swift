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

@implementation NodeUnaryOperator : Node
@synthesize uoperator = _uoperator;
@synthesize value = _value;
@end

@implementation NodeReal: Node
@synthesize real = _real;
@end

@implementation NodeNNInteger: Node
@synthesize nnInteger = _nnInteger;
@end

@implementation NodePi: Node
@synthesize pi = _pi;
@end

@implementation  NodeId: Node
@synthesize s_id = _s_id;
@end

@implementation NodeArgument: Node
@synthesize nodeId = _nodeId;
@synthesize nodeNNInteger = _nodeNNInteger;
@end

@implementation NodeUop: Node
@synthesize uopid = _uopid;
@synthesize value1 = _value1;
@synthesize value2 = _value2;
@end

@implementation ParseTree

+(Node*) createNode: (NodeType) nodeType left: (Node*) leftOperand right: (Node*) rightOperand {
    Node *node = [[Node alloc] init];
    node.nodeType = nodeType;
    node.leftOperand = leftOperand;
    node.rightOperand = rightOperand;
    return node;
}

+(NodeRelational*) createRelationalNode: (RelationalOperator) relationalOperator left: (Node*) leftOperand right: (Node*) rightOperand {
    NodeRelational *node = [[NodeRelational alloc] init];
    node.nodeType = N_RELATIONAL;
    node.leftOperand = leftOperand;
    node.rightOperand = rightOperand;
    return node;
}

+(NodeEquality*) createEqualityNode: (EqualityOperator) equalityOperator left: (Node*) leftOperand right: (Node*) rightOperand {
    NodeEquality *node = [[NodeEquality alloc] init];
    node.nodeType = N_EQAULITY;
    node.leftOperand = leftOperand;
    node.rightOperand = rightOperand;
    return node;
}

+(NodeSymbolRef*) createSymbolRefNode: (SymbolObject *) symbol {
    NodeSymbolRef *node = [[NodeSymbolRef alloc] init];
    node.nodeType = N_SYMBOL;
    node.symbol = symbol;
    return node;
}

+(NodeIf*) createIfNode: (Node *) branch {
    NodeIf *node = [[NodeIf alloc] init];
    node.nodeType = N_IF;
    node.if_branch = branch;
    return node;
}

+(NodeUop*) createUOpNode: (NSString*) uop object1: (Node*) value1 object2: (Node*) value2  {
    NodeUop *node = [[NodeUop alloc] init];
    node.nodeType = N_UOP;
    node.uopid = uop;
    node.value1 = value1;
    node.value2 = value2;
    return node;
}


+(NodeAssignment*) createAssigmentNode:(SymbolObject *) symbol withObject: (Node*) value {
    NodeAssignment *node = [[NodeAssignment alloc] init];
    node.nodeType = N_ASSIGN;
    node.symbol = symbol;
    node.value = value;
    return node;
}

+(NodeUnaryOperator*) createUnaryOpNode: (NSString*) unaryop withObject: (Node*) value {
    NodeUnaryOperator *node = [[NodeUnaryOperator alloc] init];
    node.nodeType = N_UNARY;
    node.uoperator = unaryop;
    node.value = value;
    return node;
}

+(NodeArgument*) createArgumentNode: (NodeId*) idNode withObject: (NodeNNInteger*) value {
    NodeArgument *node = [[NodeArgument alloc] init];
    node.nodeType = N_ARG;
    node.nodeId = idNode;
    node.nodeNNInteger = value;
    return node;
}

+(NodeReal*) createRealNodeWithValue: (float) value {
    NodeReal *node = [[NodeReal alloc] init];
    node.nodeType = N_REAL;
    node.real = value;
    return node;
}

+(NodeNNInteger*) createNNIntegerNodeWithValue: (int) value {
    NodeNNInteger *node = [[NodeNNInteger alloc] init];
    node.nodeType = N_NNINTEGER;
    node.nnInteger = value;
    return node;
}

+(NodePi*) createPiNodeWithValue: (double) value {
    NodePi *node = [[NodePi alloc] init];
    node.nodeType = N_PI;
    node.pi = value;
    return node;
}

+(NodeId*) createIdNodeWithValue: (NSString*) value {
    NodeId *node = [[NodeId alloc] init];
    node.nodeType = N_ID;
    node.s_id = value;
    return node;
}


@end
