//
//  ParserBlocks.m
//  qiskit
//
//  Created by Joe Ligman on 5/20/17.
//  Copyright © 2017 IBM. All rights reserved.
//

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
