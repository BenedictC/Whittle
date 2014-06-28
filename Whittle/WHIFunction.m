//
//  WHIFunction.m
//  Whittle
//
//  Created by Benedict Cohen on 08/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIFunction.h"

#import "WHIEdgeSet.h"
#import "WHIInvocation.h"

#import <objc/runtime.h>



@implementation WHIFunction

#pragma mark - factory
+(instancetype)functionWithBlock:(WHIEdgeOperation)block
{
    return [[self alloc] initWithBlock:block];
}



#pragma mark - instance life cycle
-(instancetype)initWithBlock:(WHIEdgeOperation)block
{
    self = [super init];
    if (self == nil) return nil;
    
    _block = [block copy];
    
    return self;
}



#pragma mark - execution
-(id<WHIEdgeSet>)executeWithEdge:(id<WHIEdge>)edge arguments:(NSArray *)arguments bindings:(NSDictionary *)bindings error:(NSError **)outError
{
    WHIEdgeOperation block = self.block;

    return block(edge, arguments, bindings, outError);
}

@end


#define FAIL(ERR_POINTER, ERROR) do{ \
if (ERR_POINTER != NULL) *ERR_POINTER = ERROR; \
return nil; \
} while (NO);


#pragma mark - evaluation
@implementation WHIFunction (Execution)

+(WHIFunction *)executeInvocationOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> initialEdge, NSArray *arguments, NSDictionary *bindings, NSError **outError){
        //Unpack arguments
        id<WHIEdgeSet> inputEdgeSet = arguments[0];
        WHIInvocation *invocation = arguments[1];
        if (inputEdgeSet == nil || invocation == nil) FAIL(outError, [NSError errorWithDomain:@"" code:0 userInfo:nil]);

        //Resolve the references
        WHIFunction *function = bindings[invocation.functionName];
        if (function == NULL) {
            NSString *description = [NSString stringWithFormat:@"Function not found for binding named %@", invocation.functionName];
            FAIL(outError, [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: description}]);
        }

        //Create output values
        WHIEdgeSet *outputEdgeSet = [WHIEdgeSet new];
        NSError *error;

        //Apply the function to each path in the pathSet
        for (id<WHIEdge> edge in inputEdgeSet) {

            WHIEdgeSet *subEdgeSet = [function executeWithEdge:edge arguments:invocation.arguments bindings:bindings error:&error];
            BOOL didError = (subEdgeSet == nil);
            if (didError) {
                if (outError != NULL) *outError = error;
                return nil;
            }

            [outputEdgeSet addEdgesFromEdgeSet:subEdgeSet];
        }

        return outputEdgeSet;
    })];
}



+(WHIFunction *)executeInvocationChainOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> initialEdge, NSArray *chainArguments, NSDictionary *bindings, NSError **outError){
        //Unpack arguments
        id rootObject = chainArguments[0];
        NSArray *invocations = chainArguments[1];
        WHIFunction *executeInvocationOperation = [WHIFunction executeInvocationOperation];
        NSCParameterAssert(rootObject != nil && invocations != nil); //TODO: Replace with outError

        //Prepare for the first invocation
        NSDictionary *userInfo = nil; //TODO:
        WHIEdgeSet *rootEdgeSet = [WHIEdgeSet edgeSetWithEdgeToDestinationObject:rootObject preceedingEdge:nil userInfo:userInfo];

        //Invoke the function on every object return by the previous function.
        NSMutableArray *edgeSetStack = [NSMutableArray arrayWithObject:rootEdgeSet];
        WHIEdgeSet *preceedingEdgeSet = rootEdgeSet;
        for (WHIInvocation *invocation in invocations) {

            NSArray *invocationArguments = @[preceedingEdgeSet, invocation];
            WHIEdgeSet *currentEdgeSet = [executeInvocationOperation executeWithEdge:nil arguments:invocationArguments bindings:bindings error:outError];
            BOOL didError = (currentEdgeSet == nil);
            if (didError) {
                //TODO: Create wrapper error for outError.
                return nil;
            }
            //TODO: Why do we store this? We never use the stack.
            [edgeSetStack addObject:currentEdgeSet];

            //Prep for the next invocation
            preceedingEdgeSet = currentEdgeSet;
        }
        
        return preceedingEdgeSet;
    })];
}

@end



#pragma mark - helper functions
typedef NS_ENUM(NSUInteger, WHIFunctionObjectType) {
    WHIFunctionObjectTypeKeyedCollection,
    WHIFunctionObjectTypeIndexedCollection,
    WHIFunctionObjectTypeArbitaryObject
};



static BOOL isKeyedCollection(id object) {
    return [object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSMapTable class]];
}



static BOOL isIndexedCollection(id object) {
    return [object respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)];
}



static WHIFunctionObjectType objectTypeOfObject(id object) {
    if (isKeyedCollection(object)) return WHIFunctionObjectTypeKeyedCollection;
    if (isIndexedCollection(object)) return WHIFunctionObjectTypeIndexedCollection;
    return WHIFunctionObjectTypeArbitaryObject;
}



static NSArray *allKeysInObject(id object) {
    NSCParameterAssert(object);

    //Handle special cases of Cocoa collection keyed collection classes
    if (isKeyedCollection(object)) {
        //NSDictionary & NSMapTable
        return [[[object keyEnumerator] allObjects] sortedArrayUsingSelector:@selector(compare:)];
    }

    //Generic case of an arbitary object. We enumerate all '@property's using refelection and collect their names.
    unsigned int outPropertyCount;
    objc_property_t *properties = class_copyPropertyList([object class], &outPropertyCount);
    NSMutableArray *allKeys = [NSMutableArray arrayWithCapacity:outPropertyCount];

    for (int idx = 0; idx < outPropertyCount; idx++) {
        objc_property_t property = properties[idx];
        [allKeys addObject:@(property_getName(property))];
    }

    return [allKeys sortedArrayUsingSelector:@selector(compare:)];
}



static NSString *keyForValueInDictionary(id value, NSDictionary *dictionary) {
    return [[dictionary allKeysForObject:value] lastObject];
}



@implementation WHIFunction (EdgeOperations)

+(WHIFunction *)rootNodeOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> initialEdge, NSArray *arguments, NSDictionary *bindings, NSError **outError){

        id<WHIEdge>edge = initialEdge;

        while (edge.preceedingEdge != nil) edge = edge.preceedingEdge;

        return [WHIEdgeSet edgeSetWithEdge:edge];
    })];
}



+(WHIFunction *)preceedingNodeOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> edge, NSArray *arguments, NSDictionary *bindings, NSError **outError){
        id<WHIEdge> preceedingNode = edge.preceedingEdge;

        return (preceedingNode != nil) ? [WHIEdgeSet edgeSetWithEdge:preceedingNode] : [WHIEdgeSet new];
    })];
}



+(WHIFunction *)endpointNodesOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> edge, NSArray *arguments, NSDictionary *bindings, NSError **outError){
        id object = edge.destinationObject;

        //Handle dictionaries and mapTables to use the proper key.
        switch (objectTypeOfObject(object)) {
            case WHIFunctionObjectTypeKeyedCollection: {
                WHIEdgeSet *nodeSet = [WHIEdgeSet new];
                for (NSString *key in allKeysInObject(object)) {
                    id childObject = [object objectForKey:key]; //Note that we're using objectForKey: and not valueForKey:.
                    NSDictionary *userInfo = nil; //TODO:
                    [nodeSet addEdgeToDestinationObject:childObject preceedingEdge:edge userInfo:userInfo];
                }
                return nodeSet;
            }

                //Handle enumerable objects. This handles other cocoa object collections (i.e. NSArray, NSSet, NSOrderedSet)
            case WHIFunctionObjectTypeIndexedCollection: {
                WHIEdgeSet *nodeSet = [WHIEdgeSet new];
                NSUInteger idx = 0;
                for (id childObject in object) {
                    NSDictionary *userInfo = nil; //TODO:
                    [nodeSet addEdgeToDestinationObject:childObject preceedingEdge:edge userInfo:userInfo];
                    idx++;
                }
                return nodeSet;
            }

                //Default to treating as an arbitary objects
            case WHIFunctionObjectTypeArbitaryObject: {
                WHIEdgeSet *nodeSet = [WHIEdgeSet new];
                for (NSString *key in allKeysInObject(object)) {
                    id childObject = [object valueForKey:key];
                    NSDictionary *userInfo = nil; //TODO:
                    [nodeSet addEdgeToDestinationObject:childObject preceedingEdge:edge userInfo:userInfo];
                }
                return nodeSet;
            }
        }

        NSCAssert(NO, @"Unrecognized collection type.");
        return nil;
    })];
}



+(WHIFunction *)allNodesOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> initialEdge, NSArray *arguments, NSDictionary *bindings, NSError **outError){

        //Walk graph breadth first
        NSMutableArray *edgeStack = [NSMutableArray arrayWithObject:initialEdge];
        NSMutableSet *visitedNodes = [NSMutableSet setWithObject:initialEdge.destinationObject];
        WHIEdgeSet *allEdges = [WHIEdgeSet edgeSetWithEdge:initialEdge];

        while ([edgeStack count] > 0) {
            //dequeue a node
            id<WHIEdge> currentEdge = edgeStack[0];
            [edgeStack removeObjectAtIndex:0];

            //Get all the edges that strart from currentEdge.node
            WHIEdgeSet *edgeSet = [[WHIFunction endpointNodesOperation] executeWithEdge:currentEdge arguments:arguments bindings:bindings error:outError];
            if (edgeSet == nil) return nil; //There was an error - endpointNodesOperation will have created the error object.

            //Add the results to returned node set
            [allEdges addEdgesFromEdgeSet:edgeSet];

            //Which of the tail objects do we need to walk?
            for (id<WHIEdge>childEdge in edgeSet) {
                id connectedNode = childEdge.destinationObject;
                //Do we need to walk the edges of the node
                BOOL hasAlreadyVisitedNode = [visitedNodes containsObject:connectedNode];
                if (!hasAlreadyVisitedNode) [edgeStack addObject:childEdge]; //To change to a depth first walk change addObject: to insert:AtIndex:0.

                [visitedNodes addObject:connectedNode];
            }
        }

        return allEdges;
    })];
}



+(WHIFunction *)pickOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> edge, NSArray *arguments, NSDictionary *bindings, NSError **outError){
        //Unpack arguments
        id subscript = arguments[0];
        id object = edge.destinationObject;

        BOOL isNumericSubscript = [subscript isKindOfClass:[NSNumber class]];
        if (isNumericSubscript) {
            NSInteger idx = [subscript integerValue];

            if ([object respondsToSelector:@selector(objectAtIndex:)]) {
                id value = [object objectAtIndex:idx];
                NSDictionary *userInfo = nil; //TODO:
                return [WHIEdgeSet edgeSetWithEdgeToDestinationObject:value preceedingEdge:edge userInfo:userInfo];
            }

            if ([object respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
                NSInteger enumingIdx = 0;
                for (id value in object) {
                    if (enumingIdx == idx) {
                        NSDictionary *userInfo = nil; //TODO:
                        return [WHIEdgeSet edgeSetWithEdgeToDestinationObject:value preceedingEdge:edge userInfo:userInfo];
                    }
                    enumingIdx++;
                }
            }

        } else {
            id key = subscript;
            id value = [object valueForKey:key];
            NSDictionary *userInfo = nil; //TODO:
            return [WHIEdgeSet edgeSetWithEdgeToDestinationObject:value preceedingEdge:edge userInfo:userInfo];

        }

        return nil;
    })];
}



+(WHIFunction *)filterOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> edge, NSArray *arguments, NSDictionary *bindings,  NSError **outError){
        //TODO: Convert these asserts to NSErrors
        NSCAssert(arguments.count == 1, @"Incorrect number of arguments. Filter expects arguments of type: [string].");
        //Unpack arguments
        NSString *predicateFormatString = arguments[0];
        NSCAssert([predicateFormatString isKindOfClass:[NSString class]], @"Expect NSString but found %@ .", NSStringFromClass([predicateFormatString class]));

        id object = edge.destinationObject;
        WHIEdgeSet *nodeSet = [WHIEdgeSet new];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormatString];
        NSMutableDictionary *mergedBindings = [bindings mutableCopy];
        //TODO: Should these be log statements? Would it be better to fail and set the error?
        if (mergedBindings[@"KEY"] != nil) {
            NSLog(@"Bindings dictionary already contains a value for KEY. This value will be overwritten when evaluating filter predicate.");
        }
        if (mergedBindings[@"INDEX"] != nil) {
            NSLog(@"Bindings dictionary already contains a value for INDEX. This value will be overwritten when evaluating filter predicate.");
        }
        if (mergedBindings[@"VALUE"] != nil) {
            NSLog(@"Bindings dictionary already contains a value for VALUE. This value will be overwritten when evaluating filter predicate.");
        }

        switch (objectTypeOfObject(object)) {
            case WHIFunctionObjectTypeKeyedCollection:
            case WHIFunctionObjectTypeArbitaryObject:
                for (NSString *key in allKeysInObject(object)) {
                    //add KEY and VALUE to bindings.
                    id value = [object valueForKey:key];
                    mergedBindings[@"KEY"] = key;
                    mergedBindings[@"INDEX"] = @(NSNotFound);
                    mergedBindings[@"VALUE"] = value;
                    BOOL isMatch = [predicate evaluateWithObject:object substitutionVariables:mergedBindings];
                    NSDictionary *userInfo = nil; //TODO: What do we put in the userInfo?
                    if (isMatch) [nodeSet addEdgeToDestinationObject:value preceedingEdge:edge userInfo:userInfo];
                }
                break;

            case WHIFunctionObjectTypeIndexedCollection: {
                NSInteger idx = 0;
                for (id value in object) {
                    //add KEY and VALUE to bindings.
                    mergedBindings[@"KEY"] = @"";
                    mergedBindings[@"INDEX"] = @(idx);
                    mergedBindings[@"VALUE"] = value;
                    BOOL isMatch = [predicate evaluateWithObject:object substitutionVariables:mergedBindings];
                    NSDictionary *userInfo = nil; //TODO: What do we put in the userInfo?
                    if (isMatch) [nodeSet addEdgeToDestinationObject:value preceedingEdge:edge userInfo:userInfo];

                    idx++;
                }

                break;
            }
        }

        return nodeSet;
    })];
}

@end



@implementation WHIFunction (SetOperations)

+(WHIFunction *)unionOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> edge, NSArray *unionArguments, NSDictionary *bindings, NSError **outError){
        id object = edge.destinationObject;
        WHIEdgeSet *edgeSet = [WHIEdgeSet new];
        WHIFunction *evaluateChainOperation = [WHIFunction executeInvocationChainOperation];

        //TODO: Is it wise to loop rather than expecting explicitly 2 chains?
        for (NSArray *invocationChain in unionArguments) {

            NSArray *arguments = @[object, invocationChain];
            WHIEdgeSet *childEdgeSet = [evaluateChainOperation executeWithEdge:nil arguments:arguments bindings:bindings error:outError];
            BOOL didError = (childEdgeSet == nil);
            if (didError) {
                //TODO: Create wrapper error for outError.
                return nil;
            }

            [edgeSet addEdgesFromEdgeSet:childEdgeSet];
        }

        return edgeSet;
    })];
}

//TODO: +(WHIFunction *)minusOperation;       //Returns a set with the objects of the query removed from the receiver/
//TODO: +(WHIFunction *)intersectOperation;

@end
