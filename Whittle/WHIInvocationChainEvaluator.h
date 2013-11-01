//
//  WHIInvocationChainEvaluator.h
//  Whittle
//
//  Created by Benedict Cohen on 26/07/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WHIPathSet;



@interface WHIInvocationChainEvaluator : NSObject

-(id)initWithInvocationChain:(NSArray *)invocations;
@property(nonatomic, readonly) NSArray *invocations;

-(id<WHIPathSet>)evaluateWithObject:(id)rootObject bindings:(NSDictionary *)bindings error:(NSError **)outError;

@end
