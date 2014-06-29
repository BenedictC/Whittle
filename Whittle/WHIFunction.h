//
//  WHIFunction.h
//  Whittle
//
//  Created by Benedict Cohen on 08/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 WHIFunction represent the functions used when executing a Whittle query. WHIFunction essentially wrap a Blocks and 
 provides a method to execute it. Using WHIFuction instead of a plain block means that instances can be compare with 
 isEqual: which is not possible with blocks (the result is always NO). WHIFunction also provides class methods for
 common operations.

 */

#import "WHIEdgeProtocols.h"


/**
 Type signature for blocks used in WHIFunction.

 @param edge      The edge object that the function will be applied to.
 @param arguments An array of objects used by the function. The values are specified per function.
 @param environment  Dictionary that some function use to fetch values and also contains functions.
 @param error     Error giving reason for invocation failure.

 @return An object conforming to WHIEdgeSet.
 */
typedef id<WHIEdgeSet> (^WHIFunctionBlock)(id<WHIEdge> edge, NSArray *arguments, NSDictionary *environment, NSError **error);





@interface WHIFunction : NSObject

+(instancetype)functionWithBlock:(WHIFunctionBlock)block;
-(instancetype)initWithBlock:(WHIFunctionBlock)block;
@property(nonatomic, copy, readonly) WHIFunctionBlock block;

-(id<WHIEdgeSet>)executeWithEdge:(id<WHIEdge>)edge arguments:(NSArray *)arguments environment:(NSDictionary *)environment error:(NSError **)outError;

@end



@interface WHIFunction (EdgeOperations)

#pragma mark Navigating backwards
/**
 Returns the root node.
 Arguments form: nil
 */
+(WHIFunction *)rootNodeOperation;
/**
 An operation that returns the preceeding node, i.e. path.preceedingEdge
 Arguments form: nil
 */
+(WHIFunction *)preceedingNodeOperation; //Returns the preceeding node in the path.

//TODO: Document what the arguments are for the operations
#pragma mark Navigating forwards
/**
 //Returns all endpoints connected to the current node.
 Arguments form: nil
 */
+(WHIFunction *)endpointNodesOperation;
/**
 //Returns all endpoint connected to the current node that that match the supplied predicate.
 Arguments form: nil
 */
+(WHIFunction *)filterOperation;
/**
//Returns all nodes that can be reached from the current node.
 Arguments form: nil
 */
+(WHIFunction *)allNodesOperation;
/**
//Returns the first object with key/index that exactly matches a collection.
 Arguments form: nil
 */
+(WHIFunction *)pickOperation;

@end



@interface WHIFunction (TestOperations)
+(WHIFunction *)passthroughOperation;
+(WHIFunction *)emptySetOperation;
+(WHIFunction *)failOperation;
@end
