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

+(Node*) createMainProgram: (Node*) magic include: (Node*) incld  program: (Node*) program {
//    NodeMainProgram *node = [[NodeMainProgram alloc] initWithMagic:magic version:version incld: incld program:program];
//    return node;
    return nil;
}

+(Node*) createProgram: (Node*) program statement: (Node*) statement {
    
    if (program == nil) {
        NodeProgram *nprogram = [[NodeProgram alloc] initWithStatement:statement];
        return nprogram;
    } else {
        NodeProgram *p = (NodeProgram*)program;
        [p addStatementWithStatement:statement];
    }
    return program;
}

+(Node*) createInclude: (NSString*) file {
    NodeInclude *node = [[NodeInclude alloc] initWithFile:file];
    return node;
}

+(Node*) createInt: (int) integer {
    NodeNNInt *node = [[NodeNNInt alloc] initWithValue: integer];
    return node;
}

+(Node*) createReal: (float) real {
    NodeReal *node = [[NodeReal alloc] initWithId: real];
    return node;
}

+(Node*) createMagic: (Node*) real {
    NodeMagic *node = [[NodeMagic alloc] initWithVersion:real];
    return node;
}

+(Node*) createId: (NSString*) identifer line: (int) line {
    NodeId *node = [[NodeId alloc] initWithIdentifier:identifer line:line];
    return node;
}

+(Node*) createIdlist: (Node*) idlist identifier: (Node*) identifier {
    
    if (idlist == nil) {
        NodeIdList *nodeIdList = [[NodeIdList alloc] initWithIdentifier: identifier];
        return nodeIdList;
    } else {
        NodeIdList *nodeIdList = (NodeIdList*)idlist;
        [nodeIdList addIdentifierWithIdentifier:identifier];
    }
    return idlist;
}

+(Node*) createPrimaryList: (Node*) list primary: (Node*) primary {
//    if (idlist == nil) {
//        NodeIdList *nodeIdList = [[NodeIdList alloc] initWithIdentifier: identifier];
//        return nodeIdList;
//    } else {
//        NodeIdList *nodeIdList = (NodeIdList*)idlist;
//        [nodeIdList addIdentifierWithIdentifier:identifier];
//    }
//    return idlist;
    return nil;
}

+(Node*) createQReg: (Node*) indexed_id {
    NodeQreg *node = [[NodeQreg alloc] initWithIndexedid:indexed_id line:0 file:@""]; // FIXME line, file
    return node;
}

+(Node*) createCReg: (Node*) indexed_id {
//    NodeCreg *node = [[NodeCreg alloc] init];
    return nil;
}

+(Node*) createGate: (Node*) identifier list1: (Node*) list1 list2: (Node*) list2 list3: (Node*) list3 {
//    NodeGateDecl *node = [[NodeGateDecl alloc] initWithGate: gate identifier:ident idlist1:idlist1 idlist2:idlist2];
//    return node;
    return nil;
}

+(Node*) createGateBody: (Node*) goplist {
    return nil;
}

+(Node*) createGateOpList: (Node*) goplist gate_op: (Node*) gop {
    return nil;
}

+(Node*) createCustomUnitary: (Node*) identifier list: (Node*) list list2: (Node*) list2 {
    return nil;
}

+(Node*) createCX: (Node*) arg1 arg2: (Node*) arg2 {
    return nil;
}

+(Node*) createUniversalUnitary: (Node*) list1 list2: (Node*) list2 {
    NodeUniversalUnitary *node = [[NodeUniversalUnitary alloc] initWithExplist:list1 indexedid:list2];
    return node;
}


+(Node*) createOpaque: (Node*) identifier list1: (Node*) list1 list2: (Node*) list2 {
    return nil;
}

+(Node*) createMeasure: (Node*) argument1 argument: (Node*) argument2 {
    return nil;
}

+(Node*) createBarrier: (Node*) primarylist {
    return nil;
}

+(Node*) createReset: (Node*) identifier {
    return nil;
}

+(Node*) createIf: (Node*) identifier nninteger: (Node*) integer quantum_op: (Node*) qop {
    return nil;
}

+(Node*) createIndexedId: (Node*) identifier index: (Node*) nninteger {
//    NodeIndexedId *node = [[NodeIndexedId alloc] initWithIdentifier:identifier index:nninteger];
//    return node;
    return nil;
}

+(Node*) createExternal: (Node*) identifier external: (NSString*) external {
    return nil;
}

+(Node*) createPrefixOperation: (NSString*) op operand: (Node*) o {
    NodePrefix *node = [[NodePrefix alloc] initWithOp:op children: @[o]];
    return node;
}

+(Node*) createBinaryOperation: (NSString*) op operand1: (Node*) o1 operand2: (Node*) o2 {
    NodeBinaryOp *node = [[NodeBinaryOp alloc] initWithOp:op children: @[o1, o2]];
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


+(SymbolTable*) symbolTable {
    static SymbolTable *symbol_table = nil;
    if (symbol_table == nil) {
        symbol_table = [SymbolTable alloc];
    }
    return symbol_table;
}

@end
