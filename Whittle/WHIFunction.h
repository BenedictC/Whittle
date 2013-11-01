//
//  WHIFunction.h
//  Whittle
//
//  Created by Benedict Cohen on 08/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 WHIFunction is a wrapper for blocks. Blocks cannot be compared with isEqual: (the result is always NO). Wrapping a
 block allows them to be compared.
 
 We use id as the type of the block so that arbitary blocks types can be used. (Blocks are actually of type NSBlock *
 but this is a private implementation detail so we cannot rely on it).
 
 */



@interface WHIFunction : NSObject

+(instancetype)functionWithBlock:(id)block;
-(id)initWithBlock:(id)block;
@property(nonatomic, copy, readonly) id block;

@end
