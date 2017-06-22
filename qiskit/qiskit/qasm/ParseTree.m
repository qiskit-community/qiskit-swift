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

+(Node*) createMainProgram: (Node*) magic version: (Node*) version include: (Node*) incld  program: (Node*) program {
    NodeMainProgram *node = [[NodeMainProgram alloc] initWithMagic:magic version:version incld: incld program:program];
    return node;
}

+(Node*) createProgramNode: (Node*) program statement: (Node*) statement {
    
    if (program == nil) {
        NodeProgram *nprogram = [[NodeProgram alloc] initWithProgram: program statement: statement];
        return nprogram;
    } else {
        NodeProgram *p = (NodeProgram*)program;
        [p addStatementWithStatement:statement];
    }
    return program;
}

+(Node*) createIncludeNode: (NSString*) file {
    NodeInclude *node = [[NodeInclude alloc] initWithFile:file];
    return node;
}

+(Node*) createStatmentNode: (Node*) p1 p2: (Node*) p2 p3: (Node*) p3 p4: (Node*) p4 {
    NodeStatment *node = [[NodeStatment alloc] initWithP1:p1 p2:p2 p3:p3 p4:p4];
    return node;
}

+(Node*) createDeclNode: (Node*) reg identifier: (Node*) ident nninteger: (Node*) nninteger {
    NodeDecl *node = [[NodeDecl alloc] initWithOp:reg identifier:ident nninteger: nninteger];
    return node;
}

+(Node*) createGateDeclNode: (Node*) gate identifier: (Node*) ident idlist1: (Node*) idlist1 idlist2: (Node*) idlist2 {
    NodeGateDecl *node = [[NodeGateDecl alloc] initWithGate: gate identifier:ident idlist1:idlist1 idlist2:idlist2];
    return node;
}

+(Node*) createGoplistNode: (Node*) barrier uop: (Node*) uop idlist: (Node*) idlist goplist: (Node*) goplist {
  
    if (goplist == nil) {
        if (uop != nil) {
            NodeGoplist *nodeGopList = [[NodeGoplist alloc] initWithUop:uop];
            return nodeGopList;
        } else if (barrier != nil && idlist != nil) {
            NodeGoplist *nodeGopList = [[NodeGoplist alloc] initWithBarrier:barrier idlist:idlist];
            return nodeGopList;
       }
    } else {
        if (uop != nil) {
            NodeGoplist *nodeGopList = (NodeGoplist*) goplist;
            [nodeGopList addUopWithUop:uop];
        } else if (barrier != nil && idlist != nil) {
            NodeGoplist *nodeGopList = (NodeGoplist*) goplist;
            [nodeGopList addBarrierIdlistWithBarrier:barrier idlist:idlist];
        }
    }
    return goplist;
}

+(Node*) createQopNode: (Node*) o1 object2: (Node*) o2 object3: (Node*) o3 {
    NodeQop *node = [[NodeQop alloc] initWithObject1:o1 object2:o2 object3:o3];
    return node;
}

+(Node*) createUniversalUnitary: (Node*) o1 object2: (Node*) o2 object3: (Node*) o3 {
    
    if ([o1 isKindOfClass: NodeId.class]) {
        NodeCustomUnitary *node = [[NodeCustomUnitary alloc] initWithIdentifier:o1 anylist:o2 explist:o3];
        return node;
    }
    
    NodeUniversalUnitary *node = [[NodeUniversalUnitary alloc] initWithIdentifier:o1 explistorarg: o2 argument: o3];
    return node;
}

+(Node*) createAnylistNode: (Node*) list {
    NodeAnyList *node = [[NodeAnyList alloc] initWithList:list];
    return node;
}

+(Node*) createIdlistNode: (Node*) idlist identifier: (Node*) identifier {
    
    if (idlist == nil) {
        NodeIdList *nodeIdList = [[NodeIdList alloc] initWithIdentifier: identifier];
        return nodeIdList;
    } else {
        NodeIdList *nodeIdList = (NodeIdList*)idlist;
        [nodeIdList addIdentifierWithIdentifier:identifier];
    }
    return idlist;
}

+(Node*) createMixedlistNode: (Node*) mixedList idlist: (Node*) idlist argument: (Node*) arg {

    if (mixedList == nil) {
        NodeMixedList *nodeMixedList = [[NodeMixedList alloc] initWithIdlist:idlist argument:arg];
        return nodeMixedList;
    } else {
        NodeMixedList *nodeMixedList = (NodeMixedList*)mixedList;
        if (idlist != nil) {
            [nodeMixedList addIdListWithIdlist:idlist];
        }
        if (arg != nil) {
            [nodeMixedList addArgumentWithArgument:arg];
        }
    }
    return mixedList;
}

+(Node*) createIndexedIdNode: (Node*) identifier parameter: (Node*) nninteger {
    NodeIndexedId *node = [[NodeIndexedId alloc] initWithIdentifier:identifier parameter:nninteger];
    return node;
}

+(Node*) createExpressionList: (Node*) elist expression: (Node*) exp {
    
    if (elist == nil) {
        NodeExpressionList *nodeExpList = [[NodeExpressionList alloc] initWithExpression:exp];
        return nodeExpList;
    } else {
        NodeExpressionList *nodeExpList = (NodeExpressionList*)elist;
        if (nodeExpList != nil) {
            [nodeExpList addExpressionWithExp:exp];
        }
    }
    return elist;
}
    
+(Node*) createBinaryOperation: (NSString*) op operand1: (Node*) o1 operand2: (Node*) o2 {
    NodeBinaryOp *node = [[NodeBinaryOp alloc] initWithOp:op children: @[o1, o2]];
    return node;
}
    
+(Node*) createPrefixOperation: (NSString*) op operand: (Node*) o {
    NodePrefix *node = [[NodePrefix alloc] initWithOp:op children: @[o]];
    return node;
}

+(Node*) createIdNode: (NSString*) identifer line: (int) line {
    NodeId *node = [[NodeId alloc] initWithIdentifier:identifer line:line];
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

+(Node*) createBarrierNode {
    NodeBarrier *node = [[NodeBarrier alloc] init];
    return node;
}

+(Node*) createGateNode {
    NodeGate *node = [[NodeGate alloc] init];
    return node;
}

+(Node*) createCRegNode {
    NodeCreg *node = [[NodeCreg alloc] init];
    return node;
}

+(Node*) createQRegNode {
    NodeQreg *node = [[NodeQreg alloc] init];
    return node;
}

+(Node*) createCXNode {
    NodeCnot *node = [[NodeCnot alloc] init];
    return node;
}

+(Node*) createUNode {
    NodeU *node = [[NodeU alloc] init];
    return node;
}

+(Node*) createIfNode {
    NodeIf *node = [[NodeIf alloc] init];
    return node;
}

+(Node*) createMagicNode {
    NodeMagic *node = [[NodeMagic alloc] init];
    return node;
}

+(Node*) createMeasureNode {
    NodeMeasure *node =  [[NodeMeasure alloc] init];
    return node;
}

+(Node*) createOpaqueNode {
    NodeOpaque *node = [[NodeOpaque alloc] init];
    return node;
}

+(Node*) createResetNode {
    NodeReset *node =  [[NodeReset alloc] init];
    return node;
}

@end
