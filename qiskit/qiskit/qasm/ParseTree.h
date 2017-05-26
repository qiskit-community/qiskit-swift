//
//  ParserTree.h
//  qiskit
//
//  Created by Joe Ligman on 5/22/17.
//  Copyright © 2017 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SymbolTable.h"

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
@property int nodeType;
@property (nonatomic, retain) Node* leftOperand;
@property (nonatomic, retain) Node* rightOperand;
@end

@interface NodeRelational: Node
@property RelationalOperator *roperator;
@end

@interface NodeEquality: Node
@property EqualityOperator *eoperator;
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


@interface ParseTree : NSObject

+(Node*) createNode: (int) nodeType left: (Node*) leftOperand right: (Node*) rightOperand;
+(NodeRelational*) createRelationalNode: (RelationalOperator) relationalOperator left: (Node*) leftOperand right: (Node*) rightOperand;
+(NodeEquality*) createEqualityNode: (EqualityOperator) equalityOperator left: (Node*) leftOperand right: (Node*) rightOperand;
+(NodeSymbolRef*) createSymbolRefNode: (SymbolObject *) symbol;
+(NodeIf*) createIfNode: (Node *) branch;
+(NodeAssignment*) createAssigmentNode:(SymbolObject *) symbol withObject: (Node*) value;
+(NodeUnaryOperator*) createUnaryOpNode: (NSString*) unaryop withObject: (Node*) value;
+(NodeReal*) createRealNodeWithValue: (float) value;
+(NodeNNInteger*) createNNIntegerNodeWithValue: (int) value;
+(NodePi*) createPiNodeWithValue: (double) value;
@end
