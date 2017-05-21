//
//  ParserBlocks.m
//  qiskit
//
//  Created by Joe Ligman on 5/20/17.
//  Copyright © 2017 IBM. All rights reserved.
//

#import "ParserBlocks.h"

void (^ParseSuccessBlock)(float value);
void (^ParseFailBlock)(NSString *msg);
