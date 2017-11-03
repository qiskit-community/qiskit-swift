// Copyright 2017 IBM RESEARCH. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================


#import "ParseTree.h"
#import <qiskit/qiskit-Swift.h>

static NSMutableArray<Node*>* gNodes = nil;

@implementation ParseTree

+(Node*)addNode: (Node*) node {
    @synchronized(self) {
        if (node != nil) {
            if (gNodes == nil) {
                gNodes = [[NSMutableArray alloc] init];
            }
            [gNodes addObject: node];
        }
        return node;
    }
}

+(void)clearNodes {
    @synchronized(self) {
        if (gNodes != nil) {
            [gNodes release];
            gNodes = nil;
        }
    }
}

+(Node*) createBarrier: (Node*) primarylist {
    NodeBarrier *node = [[[NodeBarrier alloc] initWithList:primarylist] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createBinaryOperation: (NSString*) op operand1: (Node*) o1 operand2: (Node*) o2 {
    NodeBinaryOp *node = [[[NodeBinaryOp alloc] initWithOp:op children: @[o1, o2]] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createCX: (Node*) arg1 arg2: (Node*) arg2 {
    NodeCnot *node = [[[NodeCnot alloc] initWithArg1:arg1 arg2:arg2] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createCReg: (Node*) indexed_id {
    NodeCreg *node = [[[NodeCreg alloc] initWithIndexedid:indexed_id line:0 file:@""] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createCustomUnitary: (Node*) identifier arguments: (Node*) args bitlist: (Node*) bitlist {
    NodeCustomUnitary *node = [[[NodeCustomUnitary alloc] initWithIdentifier:identifier arguments:args bitlist:bitlist] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createExpressionList: (Node*) elist expression: (Node*) exp {
    NodeExpressionList *node = nil;
    if (elist == nil) {
        node = [[[NodeExpressionList alloc] initWithExpression:exp] autorelease];
    } else {
        node = (NodeExpressionList*)elist;
        [node addExpressionWithExp:exp];
    }
    return [ParseTree addNode:node];
}

+(Node*) createExternal: (Node*) identifier external: (NSString*) external {
    NodeExternal *node = [[[NodeExternal alloc] initWithOperation:external expression:identifier] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createGate: (Node*) identifier list1: (Node*) list1 list2: (Node*) list2 list3: (Node*) list3 {
    NodeGate *node = [[[NodeGate alloc] initWithIdentifier:identifier arguments:list1 bitlist:list2 body:list3] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createGateBody: (Node*) goplist {
    NodeGateBody *node = [[[NodeGateBody alloc] initWithGoplist:goplist] autorelease];
    return [ParseTree addNode:node];
}


+(Node*) createGopList: (Node*)goplist gate_op:(Node*) gop {
    NodeGopList *node = nil;
    if (goplist == nil) {
        node = [[[NodeGopList alloc] initWithGateop: gop] autorelease];
    } else {
        node = (NodeGopList*)goplist;
        [node addIdentifierWithGateop:gop];
    }
    return [ParseTree addNode:node];
}

+(Node*) createId: (NSString*) identifer line: (int) line {
    NodeId *node = [[[NodeId alloc] initWithIdentifier:identifer line:line] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createIdlist: (Node*) idlist identifier: (Node*) identifier {
    NodeIdList *node = nil;
    if (idlist == nil) {
        node = [[[NodeIdList alloc] initWithIdentifier: identifier] autorelease];
    } else {
        node = (NodeIdList*)idlist;
        [node addIdentifierWithIdentifier:identifier];
    }
    return [ParseTree addNode:node];
}

+(Node*) createIf: (Node*) identifier nninteger: (Node*) integer quantum_op: (Node*) qop {
    NodeIf *node = [[[NodeIf alloc] initWithIdentifier:identifier nninteger:integer qop:qop] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createInclude: (NSString*) file {
    NodeInclude *node = [[NodeInclude alloc] initWithFile:file];
    return [ParseTree addNode:node];
}

+(Node*) createIndexedId: (Node*) identifier index: (Node*) nninteger {
    NodeIndexedId *node = [[[NodeIndexedId alloc] initWithIdentifier:identifier index:nninteger] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createInt: (int) integer {
    NodeNNInt *node = [[[NodeNNInt alloc] initWithValue: integer] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createMagic: (Node*) real {
    NodeMagic *node = [[[NodeMagic alloc] initWithVersion:real] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createMainProgram: (Node*) magic include: (Node*) incld  program: (Node*) program {
    NodeMainProgram *node = [[[NodeMainProgram alloc] initWithMagic:magic incld:incld program:program] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createMeasure: (Node*) argument1 argument: (Node*) argument2 {
    NodeMeasure *node = [[[NodeMeasure alloc] initWithArg1:argument1 arg2:argument2] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createOpaque: (Node*) identifier list1: (Node*) list1 list2: (Node*) list2 {
    Node *node = [[[NodeOpaque alloc] initWithIdentifier:identifier arguments:list1 bitlist:list2] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createPrefixOperation: (NSString*) op operand: (Node*) o {
    NodePrefix *node = [[[NodePrefix alloc] initWithOp:op children: @[o]] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createPrimaryList: (Node*) list primary: (Node*) primary {
    NodePrimaryList *node = nil;
    if (list == nil) {
        node = [[[NodePrimaryList alloc]initWithIdentifier:primary] autorelease];
    } else {
        node = (NodePrimaryList*)list;
        [node addIdentifierWithIdentifier:primary];
    }
    return [ParseTree addNode:node];
}

+(Node*) createProgram: (Node*) program statement: (Node*) statement {
    NodeProgram *node = nil;
    if (program == nil) {
        node = [[[NodeProgram alloc] initWithStatement:statement] autorelease];
    } else {
        node = (NodeProgram*)program;
        [node addStatementWithStatement:statement];
    }
    return [ParseTree addNode:node];
}

+(Node*) createQReg: (Node*) indexed_id {
    NodeQreg *node = [[[NodeQreg alloc] initWithIndexedid:indexed_id line:0 file:@""] autorelease]; // FIXME line, file
    return [ParseTree addNode:node];
}

+(Node*) createReal: (double) real {
    NodeReal *node = [[[NodeReal alloc] initWithId: real] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createReset: (Node*) identifier {
    NodeReset *node = [[[NodeReset alloc] initWithIndexedid:identifier] autorelease];
    return [ParseTree addNode:node];
}

+(Node*) createUniversalUnitary: (Node*) list1 list2: (Node*) list2 {
    NodeUniversalUnitary *node = [[[NodeUniversalUnitary alloc] initWithExplist:list1 indexedid:list2] autorelease];
    return [ParseTree addNode:node];
}

@end
