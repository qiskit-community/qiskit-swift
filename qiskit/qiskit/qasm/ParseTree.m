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

void (^ParseSuccessBlock)(NSObject *node);
void (^ParseFailBlock)(int line, const char *msg);

@implementation ParseTree

static NSMutableArray<Node*>* gNodes = nil;
static NSMutableArray<NSString*>* gStrings = nil;

+(const char*) getIncludePath: (const char*) name {
    NSBundle *mainBundle = [NSBundle bundleForClass:ParseTree.self];
    NSString *libsBundlePath = [mainBundle pathForResource:@"libs" ofType:@"bundle"];
    NSString *fileName = [NSString stringWithCString:name encoding:NSASCIIStringEncoding];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@";" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *filePath = [libsBundlePath stringByAppendingString:@"/"];
    filePath = [filePath stringByAppendingString:fileName];
    return  [filePath UTF8String];
}

+(NodeIdType) addNode: (Node*) node {
    @synchronized(self) {
        if (gNodes == nil) {
            gNodes = [[NSMutableArray alloc] init];
        }
        [gNodes addObject: node];
        return gNodes.count - 1;
    }
}

+(void) clearState {
    @synchronized(self) {
        [gNodes release];
        gNodes = nil;
        [gStrings release];
        gStrings = nil;
    }
}

+(StringIdType) addString: (const char*) str {
    NSString* text = [NSString stringWithFormat:@"%s", str];
    @synchronized(self) {
        if (gStrings == nil) {
            gStrings = [[NSMutableArray alloc] init];
        }
        [gStrings addObject: text];
        return gStrings.count - 1;
    }
}

+(NSString*) getString: (StringIdType) index {
    @synchronized(self) {
        return gStrings[index];
    }
}

+(Node*) getNode: (NodeIdType) index {
    @synchronized(self) {
        return gNodes[index];
    }
}

+(void)success: (NodeIdType) mainProgram {
    if (ParseSuccessBlock) {
        ParseSuccessBlock([ParseTree getNode:mainProgram]);
    }
}

+(void)fail: (int) line msg: (const char*) msg {
    if (ParseFailBlock) {
        ParseFailBlock(line,msg);
    }
}

+(NodeIdType) createBarrier: (NodeIdType) primarylist {
    NodeBarrier *node = [[[NodeBarrier alloc] initWithList:[ParseTree getNode:primarylist]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createBinaryOperation: (const char*) op operand1: (NodeIdType) o1 operand2: (NodeIdType) o2 {
    NSString* opText = [NSString stringWithFormat:@"%s", op];
    NodeBinaryOp *node = [[[NodeBinaryOp alloc] initWithOp:opText children: @[[ParseTree getNode:o1], [ParseTree getNode:o2]]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createCX: (NodeIdType) arg1 arg2: (NodeIdType) arg2 {
    NodeCnot *node = [[[NodeCnot alloc] initWithArg1:[ParseTree getNode:arg1] arg2:[ParseTree getNode:arg2]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createCReg: (NodeIdType) indexed_id {
    NodeCreg *node = [[[NodeCreg alloc] initWithIndexedid:[ParseTree getNode:indexed_id] line:0 file:@""] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createCustomUnitary: (NodeIdType) identifier bitlist: (NodeIdType) bitlist {
    NodeCustomUnitary *node = [[[NodeCustomUnitary alloc] initWithIdentifier:[ParseTree getNode:identifier] bitlist:[ParseTree getNode:bitlist]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createCustomUnitary: (NodeIdType) identifier arguments: (NodeIdType) args bitlist: (NodeIdType) bitlist {
    NodeCustomUnitary *node = [[[NodeCustomUnitary alloc] initWithIdentifier:[ParseTree getNode:identifier] arguments:[ParseTree getNode:args] bitlist:[ParseTree getNode:bitlist]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createExpressionList: (NodeIdType) exp {
    NodeExpressionList *node = [[[NodeExpressionList alloc] initWithExpression:[ParseTree getNode:exp]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createExpressionList: (NodeIdType) elist expression: (NodeIdType) exp {
    NodeExpressionList *node = (NodeExpressionList*)[ParseTree getNode:elist];
    [node addExpressionWithExp:[ParseTree getNode:exp]];
    return [ParseTree addNode:node];
}

+(NodeIdType) createExternal: (NodeIdType) identifier external: (StringIdType) external {
    NodeExternal *node = [[[NodeExternal alloc] initWithOperation:[ParseTree getString:external] expression:[ParseTree getNode:identifier]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createGate: (NodeIdType) identifier list2: (NodeIdType) list2 list3: (NodeIdType) list3 {
    NodeGate *node = [[[NodeGate alloc] initWithIdentifier:[ParseTree getNode:identifier] bitlist:[ParseTree getNode:list2] body:[ParseTree getNode:list3]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createGate: (NodeIdType) identifier list1: (NodeIdType) list1 list2: (NodeIdType) list2 list3: (NodeIdType) list3 {
    NodeGate *node = [[[NodeGate alloc] initWithIdentifier:[ParseTree getNode:identifier] arguments:[ParseTree getNode:list1] bitlist:[ParseTree getNode:list2] body:[ParseTree getNode:list3]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createGateBody {
    NodeGateBody *node = [[[NodeGateBody alloc] init] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createGateBodyWithList: (NodeIdType) goplist {
    NodeGateBody *node = [[[NodeGateBody alloc] initWithGoplist:[ParseTree getNode:goplist]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createGopList:(NodeIdType) gop {
    NodeGopList *node = [[[NodeGopList alloc] initWithGateop: [ParseTree getNode:gop]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createGopList: (NodeIdType)goplist gate_op:(NodeIdType) gop {
    NodeGopList *node = (NodeGopList*)[ParseTree getNode:goplist];
    [node addIdentifierWithGateop:[ParseTree getNode:gop]];
    return [ParseTree addNode:node];
}

+(NodeIdType) createId: (StringIdType) identifer line: (int) line {
    NodeId *node = [[[NodeId alloc] initWithIdentifier:[ParseTree getString:identifer] line:line] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createIdlist: (NodeIdType) identifier {
    NodeIdList *node = [[[NodeIdList alloc] initWithIdentifier: [ParseTree getNode:identifier]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createIdlist: (NodeIdType) idlist identifier: (NodeIdType) identifier {
    NodeIdList *node = (NodeIdList*)[ParseTree getNode:idlist];
    [node addIdentifierWithIdentifier:[ParseTree getNode:identifier]];
    return [ParseTree addNode:node];
}

+(NodeIdType) createIf: (NodeIdType) identifier nninteger: (NodeIdType) integer quantum_op: (NodeIdType) qop {
    NodeIf *node = [[[NodeIf alloc] initWithIdentifier:[ParseTree getNode:identifier] nninteger:[ParseTree getNode:integer] qop:[ParseTree getNode:qop]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createInclude: (StringIdType) file {
    NodeInclude *node = [[NodeInclude alloc] initWithFile:[ParseTree getString:file]];
    return [ParseTree addNode:node];
}

+(NodeIdType) createIndexedId: (NodeIdType) identifier index: (NodeIdType) nninteger {
    NodeIndexedId *node = [[[NodeIndexedId alloc] initWithIdentifier:[ParseTree getNode:identifier] index:[ParseTree getNode:nninteger]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createInt: (int) integer {
    NodeNNInt *node = [[[NodeNNInt alloc] initWithValue: integer] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createMagic: (NodeIdType) real {
    NodeMagic *node = [[[NodeMagic alloc] initWithVersion:[ParseTree getNode:real]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createMainProgram: (NodeIdType) magic program: (NodeIdType) program {
    NodeMainProgram *node = [[[NodeMainProgram alloc] initWithMagic:[ParseTree getNode:magic] program:[ParseTree getNode:program]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createMainProgram: (NodeIdType) magic include: (NodeIdType) incld  program: (NodeIdType) program {
    NodeMainProgram *node = [[[NodeMainProgram alloc] initWithMagic:[ParseTree getNode:magic] incld:[ParseTree getNode:incld] program:[ParseTree getNode:program]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createMeasure: (NodeIdType) argument1 argument: (NodeIdType) argument2 {
    NodeMeasure *node = [[[NodeMeasure alloc] initWithArg1:[ParseTree getNode:argument1] arg2:[ParseTree getNode:argument2]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createOpaque: (NodeIdType) identifier list1: (NodeIdType) list1 {
    Node *node = [[[NodeOpaque alloc] initWithIdentifier:[ParseTree getNode:identifier] arguments:[ParseTree getNode:list1]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createOpaque: (NodeIdType) identifier list1: (NodeIdType) list1 list2: (NodeIdType) list2 {
    Node *node = [[[NodeOpaque alloc] initWithIdentifier:[ParseTree getNode:identifier] arguments:[ParseTree getNode:list1] bitlist:[ParseTree getNode:list2]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createPrefixOperation: (const char*) op operand: (NodeIdType) o {
    NSString* opText = [NSString stringWithFormat:@"%s", op];
    NodePrefix *node = [[[NodePrefix alloc] initWithOp:opText children: @[[ParseTree getNode:o]]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createPrimaryList: (NodeIdType) primary {
    NodePrimaryList *node = [[[NodePrimaryList alloc]initWithIdentifier:[ParseTree getNode:primary]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createPrimaryList: (NodeIdType) list primary: (NodeIdType) primary {
    NodePrimaryList *node = (NodePrimaryList*)[ParseTree getNode:list];
    [node addIdentifierWithIdentifier:[ParseTree getNode:primary]];
    return [ParseTree addNode:node];
}

+(NodeIdType) createProgram: (NodeIdType) statement {
    NodeProgram *node = [[[NodeProgram alloc] initWithStatement:[ParseTree getNode:statement]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createProgram: (NodeIdType) program statement: (NodeIdType) statement {
    NodeProgram *node = (NodeProgram*)[ParseTree getNode:program];
    [node addStatementWithStatement:[ParseTree getNode:statement]];
    return [ParseTree addNode:node];
}

+(NodeIdType) createQReg: (NodeIdType) indexed_id {
    NodeQreg *node = [[[NodeQreg alloc] initWithIndexedid:[ParseTree getNode:indexed_id] line:0 file:@""] autorelease]; // FIXME line, file
    return [ParseTree addNode:node];
}

+(NodeIdType) createReal: (double) real {
    NodeReal *node = [[[NodeReal alloc] initWithId: real] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createReset: (NodeIdType) identifier {
    NodeReset *node = [[[NodeReset alloc] initWithIndexedid:[ParseTree getNode:identifier]] autorelease];
    return [ParseTree addNode:node];
}

+(NodeIdType) createUniversalUnitary: (NodeIdType) list1 list2: (NodeIdType) list2 {
    NodeUniversalUnitary *node = [[[NodeUniversalUnitary alloc] initWithExplist:[ParseTree getNode:list1] indexedid:[ParseTree getNode:list2]] autorelease];
    return [ParseTree addNode:node];
}

@end
