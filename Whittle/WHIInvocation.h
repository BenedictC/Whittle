//
//  WHIInvocation.h
//  Whittle
//
//  Created by Benedict Cohen on 02/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol WHIEdge, WHIEdgeSet;



/*
 
 WHIInvocation is responsible for executing functions. An instance has a reference to a function and the
 arguments to pass to the function. The function does not store the actual function. When the invocation is invoked it 
 looks up the function in the environment.
 
 The function is invoked on each edge in the input set and the results are unioned together as the result.
 
 The class object provides a method execute a list of invocations which passes the output of an invocation onto the next
 invocation in the list.

 */



@interface WHIInvocation : NSObject

-(id)initWithFunctionName:(NSString *)functionName arguments:(NSArray *)arguments;
@property(nonatomic, readonly) NSString *functionName;
@property(nonatomic, readonly) NSArray *arguments;

-(id<WHIEdgeSet>)invokeWithEdgeSet:(id<WHIEdgeSet>)inputEdgeSet environment:(NSDictionary *)environment error:(NSError **)outError;

+(id<WHIEdgeSet>)executeInvocationList:(NSArray *)invocations edgeSet:(id<WHIEdgeSet>)edgeSet environment:(NSDictionary *)environment error:(NSError **)outError;

@end
