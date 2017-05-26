//
//  ParserTree.h
//  qiskit
//
//  Created by Joe Ligman on 5/22/17.
//  Copyright © 2017 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SymbolTable.h"

typedef NS_ENUM(NSInteger, NodeType) {
    N_RELATIONAL,
    N_EQAULITY,
    N_SYMBOL,
    N_IF,
    N_ASSIGN,
    N_UNARY,
    N_REAL,
    N_NNINTEGER,
    N_PI,
    N_ID,
    N_ARG,
    N_U,
    N_CX,
    N_QREG,
    N_CREG,
    N_GATE,
    N_BARRIER,
    N_OPAQUE,
    N_MEASURE,
    N_RESET,
    N_MATCHES,
    N_ADD,
    N_MINUS,
    N_MULTIPLY,
    N_DIVIDE,
    N_SQRT,
    N_EXP,
    N_EXPLIST,
    N_UOP
};

typedef NS_ENUM(NSInteger, RelationalOperator) {
    LESS,
    LESS_OR_EQUAL,
    GREATER,
    GREATER_OR_EQUAL
};

typedef NS_ENUM(NSInteger, EqualityOperator) {
    EQUAL,
    NOT_EQUAL
};


@interface Node: NSObject
@property NodeType nodeType;
@property (nonatomic, retain) Node* leftOperand;
@property (nonatomic, retain) Node* rightOperand;
@end

@interface NodeRelational: Node
@property RelationalOperator roperator;
@end

@interface NodeEquality: Node
@property EqualityOperator eoperator;
@end

@interface NodeSymbolRef: Node
@property (nonatomic, retain) SymbolObject *symbol;
@end

@interface NodeIf: Node
@property (nonatomic, retain) Node *if_branch;
@end

@interface NodeAssignment: Node
@property (nonatomic, retain) SymbolObject *symbol;
@property (nonatomic, retain) Node *value;
@end

@interface NodeUnaryOperator : Node
@property (nonatomic, retain) NSString *uoperator;
@property (nonatomic, retain) Node *value;
@end

@interface NodeReal: Node
@property float real;
@end

@interface NodeNNInteger: Node
@property int nnInteger;
@end

@interface NodePi: Node
@property double pi;
@end

@interface NodeId: Node
@property (nonatomic, retain) NSString *s_id;
@end

@interface NodeArgument: Node
@property (nonatomic, retain) NodeId *nodeId;
@property (nonatomic, retain) NodeNNInteger *nodeNNInteger;
@end

@interface NodeUop: Node
@property (nonatomic, retain) NSString *uopid;
@property (nonatomic, retain) Node *value1;
@property (nonatomic, retain) Node *value2;
@end

@interface ParseTree : NSObject

+(Node*) createNode: (NodeType) nodeType left: (Node*) leftOperand right: (Node*) rightOperand;
+(NodeRelational*) createRelationalNode: (RelationalOperator) relationalOperator left: (Node*) leftOperand right: (Node*) rightOperand;
+(NodeEquality*) createEqualityNode: (EqualityOperator) equalityOperator left: (Node*) leftOperand right: (Node*) rightOperand;
+(NodeSymbolRef*) createSymbolRefNode: (SymbolObject *) symbol;
+(NodeIf*) createIfNode: (Node *) branch;
+(NodeAssignment*) createAssigmentNode:(SymbolObject *) symbol withObject: (Node*) value;
+(NodeUnaryOperator*) createUnaryOpNode: (NSString*) unaryop withObject: (Node*) value;
+(NodeArgument*) createArgumentNode: (Node*) idNode withObject: (Node*) value;
+(NodeUop*) createUOpNode: (NSString*) uop object1: (Node*) value1 object2: (Node*) value2;
+(NodeReal*) createRealNodeWithValue: (float) value;
+(NodeNNInteger*) createNNIntegerNodeWithValue: (int) value;
+(NodePi*) createPiNodeWithValue: (double) value;
+(NodeId*) createIdNodeWithValue: (NSString*) value;
@end
