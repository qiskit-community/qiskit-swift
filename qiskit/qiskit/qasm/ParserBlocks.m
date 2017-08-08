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


#import "ParserBlocks.h"
#import <qiskit/qiskit-Swift.h>


void (^ParseSuccessBlock)(NSObject *node);
void (^ParseFailBlock)(NSString *msg);

extern const char* getIncludePath(char* yytext) {
    NSBundle *mainBundle = [NSBundle bundleForClass:ParseTree.self];
    NSString *libsBundlePath = [mainBundle pathForResource:@"libs" ofType:@"bundle"];
    NSString *fileName = [NSString stringWithCString:yytext encoding:NSASCIIStringEncoding];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@";" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *filePath = [libsBundlePath stringByAppendingString:@"/"];
    filePath = [filePath stringByAppendingString:fileName];
    return  [filePath UTF8String]; 
}
