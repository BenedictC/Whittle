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

 */

#import "WHIEdgeProtocols.h"


/**
 Type signature for blocks used in WHIFunction.

 @param edge      The edge object that the function will be applied to.
 @param arguments An array of objects used by the function. The values are specified per function.
 @param bindings  Dictionary that some function use to fetch values and also contains functions.
 @param error     Error giving reason for invocation failure.

 @return An object conforming to WHIEdgeSet.
 */
typedef id<WHIEdgeSet> (^WHIEdgeOperation)(id<WHIEdge> edge, NSArray *arguments, NSDictionary *bindings, NSError **error);





@interface WHIFunction : NSObject

+(instancetype)functionWithBlock:(WHIEdgeOperation)block;
-(instancetype)initWithBlock:(WHIEdgeOperation)block;
@property(nonatomic, copy, readonly) WHIEdgeOperation block;

-(id<WHIEdgeSet>)executeWithEdge:(id<WHIEdge>)edge arguments:(NSArray *)arguments bindings:(NSDictionary *)bindings error:(NSError **)outError;

@end



@interface WHIFunction (Execution)
//TODO: Document what the arguments are for the operations
//+(WHIFunction *)executeInvocationOperation;    //@[preceedingEdgeSet, invocation];
+(WHIFunction *)executeInvocationChainOperation; //@[rootObject, self.invocations];
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



@interface WHIFunction (SetOperations)

+(WHIFunction *)unionOperation;          //Returns the union of two nodeSets.
//TODO: +(WHIFunction *)minusOperation;       //Returns a set with the objects of the query removed from the receiver/
//TODO: +(WHIFunction *)intersectOperation;

@end
