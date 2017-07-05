//
//  ParserBlocks.h
//  qiskit
//
//  Created by Joe Ligman on 5/20/17.
//  Copyright © 2017 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

extern int yylineno;
extern const char* getIncludePath(char* yytext);
extern void (^ParseSuccessBlock)(NSObject *node);
extern void (^ParseFailBlock)(NSString *msg);

#ifndef FLEXINT_H

typedef struct yy_buffer_state *YY_BUFFER_STATE;
YY_BUFFER_STATE  yy_scan_string(const char *s);

int yyparse();

#endif
