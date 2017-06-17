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
