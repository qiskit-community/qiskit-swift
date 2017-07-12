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

+(Node*) createBarrier: (Node*) primarylist {
    NodeBarrier *node = [[[NodeBarrier alloc] initWithList:primarylist] autorelease];
    return node;
}

+(Node*) createBinaryOperation: (NSString*) op operand1: (Node*) o1 operand2: (Node*) o2 {
    NodeBinaryOp *node = [[[NodeBinaryOp alloc] initWithOp:op children: @[o1, o2]] autorelease];
    return node;
}

+(Node*) createCX: (Node*) arg1 arg2: (Node*) arg2 {
    NodeCnot *node = [[[NodeCnot alloc] initWithArg1:arg1 arg2:arg2] autorelease];
    return node;
}

+(Node*) createCReg: (Node*) indexed_id {
    NodeCreg *node = [[[NodeCreg alloc] initWithIndexedid:indexed_id line:0 file:@""] autorelease];
    return node;
}

+(Node*) createCustomUnitary: (Node*) identifier arguments: (Node*) args bitlist: (Node*) bitlist {
    NodeCustomUnitary *node = [[[NodeCustomUnitary alloc] initWithIdentifier:identifier arguments:args bitlist:bitlist] autorelease];
    return node;
}

+(Node*) createExpressionList: (Node*) elist expression: (Node*) exp {
    
    if (elist == nil) {
        NodeExpressionList *nodeExpList = [[[NodeExpressionList alloc] initWithExpression:exp] autorelease];
        return nodeExpList;
    } else {
        NodeExpressionList *nodeExpList = (NodeExpressionList*)elist;
        if (nodeExpList != nil) {
            [nodeExpList addExpressionWithExp:exp];
        }
    }
    return elist;
}

+(Node*) createExternal: (Node*) identifier external: (NSString*) external {
    NodeExternal *node = [[[NodeExternal alloc] initWithOperation:external expression:identifier] autorelease];
    return node;
}

+(Node*) createGate: (Node*) identifier list1: (Node*) list1 list2: (Node*) list2 list3: (Node*) list3 {
    NodeGate *node = [[[NodeGate alloc] initWithIdentifier:identifier arguments:list1 bitlist:list2 body:list3] autorelease];
    return node;
}

+(Node*) createGateBody: (Node*) goplist {
    NodeGateBody *node = [[[NodeGateBody alloc] initWithGoplist:goplist] autorelease];
    return node;
}


+(Node*) createGopList: (Node*)goplist gate_op:(Node*) gop {
    if (goplist == nil) {
        NodeGopList *nodeGoplist = [[[NodeGopList alloc] initWithGateop: gop] autorelease];
        return nodeGoplist;
    } else {
        NodeGopList *nodeGoplist = (NodeGopList*)goplist;
        if (nodeGoplist != nil) {
            [nodeGoplist addIdentifierWithGateop:gop];
        }
    }
    return goplist;
}

+(Node*) createId: (NSString*) identifer line: (int) line {
    NodeId *node = [[[NodeId alloc] initWithIdentifier:identifer line:line] autorelease];
    return node;
}

+(Node*) createIdlist: (Node*) idlist identifier: (Node*) identifier {
    
    if (idlist == nil) {
        NodeIdList *nodeIdList = [[[NodeIdList alloc] initWithIdentifier: identifier] autorelease];
        return nodeIdList;
    } else {
        NodeIdList *nodeIdList = (NodeIdList*)idlist;
        [nodeIdList addIdentifierWithIdentifier:identifier];
    }
    return idlist;
}

+(Node*) createIf: (Node*) identifier nninteger: (Node*) integer quantum_op: (Node*) qop {
    NodeIf *node = [[[NodeIf alloc] initWithIdentifier:identifier nninteger:integer qop:qop] autorelease];
    return node;
}

+(Node*) createInclude: (NSString*) file {
    NodeInclude *node = [[NodeInclude alloc] initWithFile:file];
    return node;
}

+(Node*) createIndexedId: (Node*) identifier index: (Node*) nninteger {
    NodeIndexedId *node = [[[NodeIndexedId alloc] initWithIdentifier:identifier index:nninteger] autorelease];
    return node;
}

+(Node*) createInt: (int) integer {
    NodeNNInt *node = [[[NodeNNInt alloc] initWithValue: integer] autorelease];
    return node;
}

+(Node*) createMagic: (Node*) real {
    NodeMagic *node = [[[NodeMagic alloc] initWithVersion:real] autorelease];
    return node;
}

+(Node*) createMainProgram: (Node*) magic include: (Node*) incld  program: (Node*) program {
    NodeMainProgram *node = [[[NodeMainProgram alloc] initWithMagic:magic incld:incld program:program] autorelease];
    return node;
}

+(Node*) createMeasure: (Node*) argument1 argument: (Node*) argument2 {
    NodeMeasure *node = [[[NodeMeasure alloc] initWithArg1:argument1 arg2:argument2] autorelease];
    return node;
}

+(Node*) createOpaque: (Node*) identifier list1: (Node*) list1 list2: (Node*) list2 {
    Node *opaque = [[[NodeOpaque alloc] initWithIdentifier:identifier arguments:list1 bitlist:list2] autorelease];
    return opaque;
}

+(Node*) createPrefixOperation: (NSString*) op operand: (Node*) o {
    NodePrefix *node = [[[NodePrefix alloc] initWithOp:op children: @[o]] autorelease];
    return node;
}

+(Node*) createPrimaryList: (Node*) list primary: (Node*) primary {
    if (list == nil) {
        NodePrimaryList *nodePrimaryList = [[[NodePrimaryList alloc]initWithIdentifier:primary] autorelease];
        return nodePrimaryList;
    } else {
        NodePrimaryList *nodePrimaryList = (NodePrimaryList*)list;
        [nodePrimaryList addIdentifierWithIdentifier:primary];
    }
    return list;
}

+(Node*) createProgram: (Node*) program statement: (Node*) statement {
    
    if (program == nil) {
        NodeProgram *nprogram = [[[NodeProgram alloc] initWithStatement:statement] autorelease];
        return nprogram;
    } else {
        NodeProgram *p = (NodeProgram*)program;
        [p addStatementWithStatement:statement];
    }
    return program;
}

+(Node*) createQReg: (Node*) indexed_id {
    NodeQreg *node = [[[NodeQreg alloc] initWithIndexedid:indexed_id line:0 file:@""] autorelease]; // FIXME line, file
    return node;
}

+(Node*) createReal: (double) real {
    NodeReal *node = [[[NodeReal alloc] initWithId: real] autorelease];
    return node;
}

+(Node*) createReset: (Node*) identifier {
    NodeReset *node = [[[NodeReset alloc] initWithIndexedid:identifier] autorelease];
    return node;
}

+(Node*) createUniversalUnitary: (Node*) list1 list2: (Node*) list2 {
    NodeUniversalUnitary *node = [[[NodeUniversalUnitary alloc] initWithExplist:list1 indexedid:list2] autorelease];
    return node;
}


+(SymbolTable*) symbolTable {
    static SymbolTable *symbol_table = nil;
    if (symbol_table == nil) {
        symbol_table = [SymbolTable alloc];
    }
    return symbol_table;
}

@end
