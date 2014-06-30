//
//  WHIFunction.m
//  Whittle
//
//  Created by Benedict Cohen on 08/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIFunction.h"

#import "WHIWalkSet.h"

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
    NSParameterAssert(block);
    self = [super init];
    if (self == nil) return nil;
    
    _block = [block copy];
    
    return self;
}



#pragma mark - execution
-(id<WHIWalkSet>)executeWithWalk:(id<WHIWalk>)edge arguments:(NSArray *)arguments environment:(NSDictionary *)environment error:(NSError **)outError
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



@implementation WHIFunction (WalkFunctions)

+(WHIFunction *)rootNodeFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(id<WHIWalk> initialWalk, NSArray *arguments, NSDictionary *environment, NSError **outError){

            id<WHIWalk>walk = initialWalk;

            while (walk.preceedingWalk != nil) walk = walk.preceedingWalk;

            return [WHIWalkSet walkSetWithWalk:walk];
        })];
    });
    return function;

}



+(WHIFunction *)preceedingNodeFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(id<WHIWalk> edge, NSArray *arguments, NSDictionary *environment, NSError **outError){
            id<WHIWalk> preceedingWalk = edge.preceedingWalk;

            return (preceedingWalk != nil) ? [WHIWalkSet walkSetWithWalk:preceedingWalk] : [WHIWalkSet new];
        })];
    });
    return function;

}



+(WHIFunction *)endpointNodesFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(id<WHIWalk> edge, NSArray *arguments, NSDictionary *environment, NSError **outError){
            id object = edge.destinationObject;

            //Handle dictionaries and mapTables to use the proper key.
            switch (objectTypeOfObject(object)) {
                case WHIFunctionObjectTypeKeyedCollection: {
                    WHIWalkSet *nodeSet = [WHIWalkSet new];
                    for (NSString *key in allKeysInObject(object)) {
                        id childObject = [object objectForKey:key]; //Note that we're using objectForKey: and not valueForKey:.
                        [nodeSet addWalkToDestinationObject:childObject label:key preceedingWalk:edge];
                    }
                    return nodeSet;
                }

                    //Handle enumerable objects. This handles other cocoa object collections (i.e. NSArray, NSSet, NSOrderedSet)
                case WHIFunctionObjectTypeIndexedCollection: {
                    WHIWalkSet *nodeSet = [WHIWalkSet new];
                    NSUInteger idx = 0;
                    for (id childObject in object) {
                        [nodeSet addWalkToDestinationObject:childObject label:@(idx) preceedingWalk:edge];
                        idx++;
                    }
                    return nodeSet;
                }

                    //Default to treating as an arbitary objects
                case WHIFunctionObjectTypeArbitaryObject: {
                    WHIWalkSet *nodeSet = [WHIWalkSet new];
                    for (NSString *key in allKeysInObject(object)) {
                        id childObject = [object valueForKey:key];
                        [nodeSet addWalkToDestinationObject:childObject label:key preceedingWalk:edge];
                    }
                    return nodeSet;
                }
            }

            NSCAssert(NO, @"Unrecognized collection type.");
            return nil;
        })];
    });
    return function;

}



+(WHIFunction *)allNodesFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(id<WHIWalk> initialWalk, NSArray *arguments, NSDictionary *environment, NSError **outError){
            //Walk graph breadth first
            NSMutableArray *edgeStack = [NSMutableArray arrayWithObject:initialWalk];
            NSMutableSet *visitedNodes = [NSMutableSet setWithObject:initialWalk.destinationObject];
            WHIWalkSet *allWalks = [WHIWalkSet walkSetWithWalk:initialWalk];

            while ([edgeStack count] > 0) {
                //dequeue a node
                id<WHIWalk> currentWalk = edgeStack[0];
                [edgeStack removeObjectAtIndex:0];

                //Get all the edges that strart from currentWalk.node
                WHIWalkSet *edgeSet = [[WHIFunction endpointNodesFunction] executeWithWalk:currentWalk arguments:arguments environment:environment error:outError];
                if (edgeSet == nil) return nil; //There was an error - endpointNodesOperation will have created the error object.

                //Add the results to returned node set
                [allWalks addWalksFromWalkSet:edgeSet];

                //Which of the tail objects do we need to walk?
                for (id<WHIWalk>childWalk in edgeSet) {
                    id connectedNode = childWalk.destinationObject;
                    //Do we need to walk the edges of the node
                    BOOL hasAlreadyVisitedNode = [visitedNodes containsObject:connectedNode];
                    if (!hasAlreadyVisitedNode) [edgeStack addObject:childWalk]; //To change to a depth first walk change addObject: to insert:AtIndex:0.

                    [visitedNodes addObject:connectedNode];
                }
            }

            return allWalks;
        })];
    });
    return function;

}



+(WHIFunction *)pickFunction
{
    
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(id<WHIWalk> edge, NSArray *arguments, NSDictionary *environment, NSError **outError){
            id object = edge.destinationObject;
            WHIWalkSet *outputWalkSet = [WHIWalkSet new];
            for (id subscript in arguments) {

                //Attempt to pick the value from a string subscript
                BOOL isStringSubscript = [subscript isKindOfClass:[NSString class]];
                if (isStringSubscript) {
                    id key = subscript;
                    id value = [object valueForKey:key];
                    if (value != nil) {
                        [outputWalkSet addWalkToDestinationObject:value label:key preceedingWalk:edge];
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
                            [outputWalkSet addWalkToDestinationObject:value label:@(idx) preceedingWalk:edge];
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
                            [outputWalkSet addWalkToDestinationObject:value label:@(idx) preceedingWalk:edge];
                        }
                        continue;
                    }

                    //TODO: Error - object does not permit integer-based picking.
                }

                //TODO: Error - subscript is not a valid subscript type.
            }

            return outputWalkSet;
        })];
    });
    return function;

}



+(WHIFunction *)filterFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(id<WHIWalk> edge, NSArray *arguments, NSDictionary *environment,  NSError **outError){
            //TODO: Convert these asserts to NSErrors
            NSCAssert(arguments.count == 1, @"Incorrect number of arguments. Filter expects arguments of type: [string].");
            //Unpack arguments
            NSString *predicateFormatString = arguments[0];
            NSCAssert([predicateFormatString isKindOfClass:[NSString class]], @"Expect NSString but found %@ .", NSStringFromClass([predicateFormatString class]));

            id object = edge.destinationObject;
            WHIWalkSet *nodeSet = [WHIWalkSet new];
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
                        if (isMatch) [nodeSet addWalkToDestinationObject:value label:key preceedingWalk:edge];
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
                        if (isMatch) [nodeSet addWalkToDestinationObject:value label:@(idx) preceedingWalk:edge];

                        idx++;
                    }

                    break;
                }
            }

        return nodeSet;
        })];
    });
    return function;

}

@end



@implementation WHIFunction (TestFunctions)

+(WHIFunction *)passthroughFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(id<WHIWalk> walk, NSArray *arguments, NSDictionary *environment, NSError **outError){
            return [WHIWalkSet walkSetWithWalk:walk];
        })];
    });
    return function;
}



+(WHIFunction *)emptySetFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(id<WHIWalk> edge, NSArray *arguments, NSDictionary *environment, NSError **outError){
            return [WHIWalkSet new];
        })];
    });
    return function;

}



+(WHIFunction *)failFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(id<WHIWalk> edge, NSArray *arguments, NSDictionary *environment, NSError **outError){
            if (outError != NULL) *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:nil];
            return nil;
        })];
    });
    return function;

}

@end
