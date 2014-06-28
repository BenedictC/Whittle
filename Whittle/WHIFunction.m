//
//  WHIFunction.m
//  Whittle
//
//  Created by Benedict Cohen on 08/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIFunction.h"

#import "WHIEdgeSet.h"

#import <objc/runtime.h>



@implementation WHIFunction

#pragma mark - factory
+(instancetype)functionWithBlock:(WHIFunctionBlock)block
{
    return [[self alloc] initWithBlock:block];
}



#pragma mark - instance life cycle
-(instancetype)initWithBlock:(WHIFunctionBlock)block
{
    self = [super init];
    if (self == nil) return nil;
    
    _block = [block copy];
    
    return self;
}



#pragma mark - execution
-(id<WHIEdgeSet>)executeWithEdge:(id<WHIEdge>)edge arguments:(NSArray *)arguments environment:(NSDictionary *)environment error:(NSError **)outError
{
    WHIFunctionBlock block = self.block;

    return block(edge, arguments, environment, outError);
}

@end


#define FAIL(ERR_POINTER, ERROR) do{ \
if (ERR_POINTER != NULL) *ERR_POINTER = ERROR; \
return nil; \
} while (NO);



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
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> initialEdge, NSArray *arguments, NSDictionary *environment, NSError **outError){

        id<WHIEdge>edge = initialEdge;

        while (edge.preceedingEdge != nil) edge = edge.preceedingEdge;

        return [WHIEdgeSet edgeSetWithEdge:edge];
    })];
}



+(WHIFunction *)preceedingNodeOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> edge, NSArray *arguments, NSDictionary *environment, NSError **outError){
        id<WHIEdge> preceedingNode = edge.preceedingEdge;

        return (preceedingNode != nil) ? [WHIEdgeSet edgeSetWithEdge:preceedingNode] : [WHIEdgeSet new];
    })];
}



+(WHIFunction *)endpointNodesOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> edge, NSArray *arguments, NSDictionary *environment, NSError **outError){
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
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> initialEdge, NSArray *arguments, NSDictionary *environment, NSError **outError){

        //Walk graph breadth first
        NSMutableArray *edgeStack = [NSMutableArray arrayWithObject:initialEdge];
        NSMutableSet *visitedNodes = [NSMutableSet setWithObject:initialEdge.destinationObject];
        WHIEdgeSet *allEdges = [WHIEdgeSet edgeSetWithEdge:initialEdge];

        while ([edgeStack count] > 0) {
            //dequeue a node
            id<WHIEdge> currentEdge = edgeStack[0];
            [edgeStack removeObjectAtIndex:0];

            //Get all the edges that strart from currentEdge.node
            WHIEdgeSet *edgeSet = [[WHIFunction endpointNodesOperation] executeWithEdge:currentEdge arguments:arguments environment:environment error:outError];
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
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> edge, NSArray *arguments, NSDictionary *environment, NSError **outError){

        id object = edge.destinationObject;
        WHIEdgeSet *outputEdgeSet = [WHIEdgeSet new];
        for (id subscript in arguments) {

            //Attempt to pick the value from a string subscript
            BOOL isStringSubscript = [subscript isKindOfClass:[NSString class]];
            if (isStringSubscript) {
                id key = subscript;
                id value = [object valueForKey:key];
                if (value != nil) {
                    NSDictionary *userInfo = nil; //TODO:
                    [outputEdgeSet addEdgeToDestinationObject:value preceedingEdge:edge userInfo:userInfo];
                }
                continue;
            }

            //Attempt to pick the value from a integer subscript
            BOOL isIntegerSubscript = [subscript isKindOfClass:[NSNumber class]];
            if (isIntegerSubscript) {
                NSInteger idx = [subscript integerValue];

                BOOL isIndexed = [object respondsToSelector:@selector(objectAtIndex:)];
                if (isIndexed) {
                    id value = [object objectAtIndex:idx];
                    if (value != nil) {
                        NSDictionary *userInfo = nil; //TODO:
                        [outputEdgeSet addEdgeToDestinationObject:value preceedingEdge:edge userInfo:userInfo];
                    }
                    continue;
                }

                BOOL isEnumerable = [object respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)];
                if (isEnumerable) {
                    id value = ^{
                        NSInteger enumingIdx = 0;
                        for (id value in object) {
                            if (enumingIdx == idx) return value;
                            enumingIdx++;
                        }
                        return (id)nil;
                    }();
                    if (value != nil) {
                        NSDictionary *userInfo = nil; //TODO:
                        [outputEdgeSet addEdgeToDestinationObject:value preceedingEdge:edge userInfo:userInfo];
                    }
                    continue;
                }

                //TODO: Error - object does not permit integer-based picking.
            }

            //TODO: Error - subscript is not a valid subscript type.
        }

        return outputEdgeSet;
    })];
}



+(WHIFunction *)filterOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> edge, NSArray *arguments, NSDictionary *environment,  NSError **outError){
        //TODO: Convert these asserts to NSErrors
        NSCAssert(arguments.count == 1, @"Incorrect number of arguments. Filter expects arguments of type: [string].");
        //Unpack arguments
        NSString *predicateFormatString = arguments[0];
        NSCAssert([predicateFormatString isKindOfClass:[NSString class]], @"Expect NSString but found %@ .", NSStringFromClass([predicateFormatString class]));

        id object = edge.destinationObject;
        WHIEdgeSet *nodeSet = [WHIEdgeSet new];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormatString];
        NSMutableDictionary *mergedEnvironment = [environment mutableCopy];
        //TODO: Should these be log statements? Would it be better to fail and set the error?
        if (mergedEnvironment[@"KEY"] != nil) {
            NSLog(@"Environment dictionary already contains a value for KEY. This value will be overwritten when evaluating filter predicate.");
        }
        if (mergedEnvironment[@"INDEX"] != nil) {
            NSLog(@"Environment dictionary already contains a value for INDEX. This value will be overwritten when evaluating filter predicate.");
        }
        if (mergedEnvironment[@"VALUE"] != nil) {
            NSLog(@"Environment dictionary already contains a value for VALUE. This value will be overwritten when evaluating filter predicate.");
        }

        switch (objectTypeOfObject(object)) {
            case WHIFunctionObjectTypeKeyedCollection:
            case WHIFunctionObjectTypeArbitaryObject:
                for (NSString *key in allKeysInObject(object)) {
                    //add KEY and VALUE to environment.
                    id value = [object valueForKey:key];
                    mergedEnvironment[@"KEY"] = key;
                    mergedEnvironment[@"INDEX"] = @(NSNotFound);
                    mergedEnvironment[@"VALUE"] = value;
                    BOOL isMatch = [predicate evaluateWithObject:object substitutionVariables:mergedEnvironment];
                    NSDictionary *userInfo = nil; //TODO: What do we put in the userInfo?
                    if (isMatch) [nodeSet addEdgeToDestinationObject:value preceedingEdge:edge userInfo:userInfo];
                }
                break;

            case WHIFunctionObjectTypeIndexedCollection: {
                NSInteger idx = 0;
                for (id value in object) {
                    //add KEY and VALUE to environment.
                    mergedEnvironment[@"KEY"] = @"";
                    mergedEnvironment[@"INDEX"] = @(idx);
                    mergedEnvironment[@"VALUE"] = value;
                    BOOL isMatch = [predicate evaluateWithObject:object substitutionVariables:mergedEnvironment];
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
