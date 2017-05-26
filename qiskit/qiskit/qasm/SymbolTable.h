//
//  SymbolTable.h
//  qiskit
//
//  Created by Joe Ligman on 5/25/17.
//  Copyright © 2017 IBM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SymbolObject: NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *value;
@end

@interface SymbolTable : NSObject

@end
