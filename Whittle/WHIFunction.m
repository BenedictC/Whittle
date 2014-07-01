//
//  WHIFunction.m
//  Whittle
//
//  Created by Benedict Cohen on 08/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIFunction.h"

#import <objc/runtime.h>

#import "WHIWalkSet.h"
#import "WHIWalk.h"
#import "WHIError.h"




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
-(WHIWalkSet *)executeWithWalk:(WHIWalkSet *)walkSet arguments:(NSArray *)arguments environment:(NSDictionary *)environment error:(NSError **)outError
{
    WHIFunctionBlock block = self.block;

    return block(walkSet, arguments, environment, outError);
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
    WHIFunctionObjectTypeArbitaryObject,
};



typedef NS_ENUM(NSUInteger, WHIFunctionSubscriptAccessType) {
    WHIFunctionSubscriptAccessTypeKVC,
    WHIFunctionSubscriptAccessTypeIndex,
    WHIFunctionSubscriptAccessTypeEnumerable,
    WHIFunctionSubscriptAccessTypeUnknown,
};



static WHIFunctionSubscriptAccessType subscriptAccessTypeForObjectAndSubscript(id object, id subscript) {
    BOOL isStringSubscript = [subscript isKindOfClass:[NSString class]];
    if (isStringSubscript) return WHIFunctionSubscriptAccessTypeKVC;

    BOOL isIntegerSubscript = [subscript isKindOfClass:[NSNumber class]];
    if (isIntegerSubscript) {
        BOOL isIndexed = [object respondsToSelector:@selector(objectAtIndex:)];
        if (isIndexed) return WHIFunctionSubscriptAccessTypeIndex;

        BOOL isEnumerable = [object respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)];
        if (isEnumerable) return WHIFunctionSubscriptAccessTypeEnumerable;
    }

    return WHIFunctionSubscriptAccessTypeUnknown;
}



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
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(WHIWalkSet * walkSet, NSArray *arguments, NSDictionary *environment, NSError **outError){

            for (WHIWalk * initalWalk in walkSet) {
                WHIWalk * walk = initalWalk;
                while (walk.preceedingWalk != nil) walk = walk.preceedingWalk;

                return [WHIWalkSet walkSetWithWalkToDestinationObject:walk.destinationObject label:nil preceedingWalk:nil];
            }
            //TODO: This must be an error!
            return nil;
        })];
    });
    return function;

}



+(WHIFunction *)preceedingNodesFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(WHIWalkSet * input, NSArray *arguments, NSDictionary *environment, NSError **outError){
            WHIWalkSet *output = [WHIWalkSet new];

            for (WHIWalk * walk in input) {
                WHIWalk * preceedingWalk = walk.preceedingWalk;
                if (preceedingWalk != nil) [output addWalk:preceedingWalk];
            }

            return output;
        })];
    });
    return function;

}



+(WHIFunction *)endpointNodesFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(WHIWalkSet * input, NSArray *arguments, NSDictionary *environment, NSError **outError){

            WHIWalkSet *output = [WHIWalkSet new];

            for (WHIWalk * walk in input) {
                id object = walk.destinationObject;

                switch (objectTypeOfObject(object)) {

                    //Handle dictionaries and mapTables to use the proper key.
                    case WHIFunctionObjectTypeKeyedCollection: {
                        for (NSString *key in allKeysInObject(object)) {
                            id childObject = [object objectForKey:key]; //Note that we're using objectForKey: and not valueForKey:.
                            [output addWalkToDestinationObject:childObject label:key preceedingWalk:walk];
                        }
                        continue;
                    }

                    //Handle enumerable objects. This handles other cocoa object collections (i.e. NSArray, NSSet, NSOrderedSet)
                    case WHIFunctionObjectTypeIndexedCollection: {
                        NSUInteger idx = 0;
                        for (id childObject in object) {
                            [output addWalkToDestinationObject:childObject label:@(idx) preceedingWalk:walk];
                            idx++;
                        }
                        continue;
                    }

                    //Default to treating as an arbitary objects
                    default:
                    case WHIFunctionObjectTypeArbitaryObject: {
                        for (NSString *key in allKeysInObject(object)) {
                            id childObject = [object valueForKey:key];
                            [output addWalkToDestinationObject:childObject label:key preceedingWalk:walk];
                        }
                        continue;
                    }
                }
            }

            return output;
        })];
    });
    return function;

}



+(WHIFunction *)allNodesFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(WHIWalkSet * initialWalkSet, NSArray *arguments, NSDictionary *environment, NSError **outError){

            WHIWalkSet *output = [WHIWalkSet new];
            NSMutableSet *nodesInOutput = [output.objects mutableCopy]; //Temporary varible to avoid repeatedlt calling output.visitedObjects.
            NSMutableArray *pendingWalks = [initialWalkSet.walks mutableCopy];
            NSMutableSet *exploredNodes = [NSMutableSet new];

            void (^addWalkToOutput)(WHIWalk *) = ^(WHIWalk *walk){
                BOOL isAlreadyInOutput = [nodesInOutput containsObject:walk.destinationObject];
                if (isAlreadyInOutput) return;

                [output addWalk:walk];
                [nodesInOutput addObject:walk.destinationObject];
            };

            //Explore pendingWalks to discover all nodes
            while ([pendingWalks count] > 0) {
                //dequeue a walk and get its' node
                WHIWalk * walk = pendingWalks[0];
                [pendingWalks removeObjectAtIndex:0];

                //If the node has already been explored then doing so again would create infinite cycles.
                id node = walk.destinationObject;
                if ([exploredNodes containsObject:node]) continue;
                [exploredNodes addObject:node];

                //A node doesn't have to have been explored to already be in the output.
                addWalkToOutput(walk);

                //Get all the edges that start from node.
                WHIWalkSet * endpoints = [[WHIFunction endpointNodesFunction] executeWithWalk:[WHIWalkSet walkSetWithWalk:walk] arguments:arguments environment:environment error:outError];
                if (endpoints == nil) return nil; //There was an error. endpointNodesFunction will have created the error object.

                //Enqueue each endpoint and conditionally add it to the output.
                for (WHIWalk * endpoint in endpoints) {
                    [pendingWalks addObject:endpoint]; //We could make walk depth-first by prepending to pendingWalks.
                    addWalkToOutput(endpoint);
                }
            }

            return output;
        })];
    });
    return function;

}



+(WHIFunction *)pickFunction
{
    
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(WHIWalkSet * walkSet, NSArray *arguments, NSDictionary *environment, NSError **outError){
            WHIWalkSet *output = [WHIWalkSet new];

            for (WHIWalk * walk in walkSet) {

                id object = walk.destinationObject;
                for (id subscript in arguments) {

                    switch (subscriptAccessTypeForObjectAndSubscript(object, subscript)) {

                        case WHIFunctionSubscriptAccessTypeKVC: {
                            //TODO: Is this correct even for NSDictionary and NSMapTable?
                            NSString *key = subscript;
                            id value = [object valueForKey:key];
                            if (value != nil) [output addWalkToDestinationObject:value label:key preceedingWalk:walk];
                            continue;
                        }

                        case WHIFunctionSubscriptAccessTypeIndex: {
                            NSInteger idx = [subscript integerValue];
                            id value = [object objectAtIndex:idx];
                            if (value != nil) [output addWalkToDestinationObject:value label:@(idx) preceedingWalk:walk];
                            continue;
                        }

                        case WHIFunctionSubscriptAccessTypeEnumerable: {
                            NSInteger idx = [subscript integerValue];
                            id value = ^{
                                NSInteger enumingIdx = 0;
                                for (id value in object) {
                                    if (enumingIdx == idx) return value;
                                    enumingIdx++;
                                }
                                return (id)nil;
                            }();
                            if (value != nil) [output addWalkToDestinationObject:value label:@(idx) preceedingWalk:walk];
                            continue;
                        }

                        case WHIFunctionSubscriptAccessTypeUnknown: {
                            //TODO: Error - subscript is not a valid subscript type.
                            return nil;
                        }
                    }
                }
            }
            return output;
        })];
    });
    return function;

}



+(WHIFunction *)filterFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(WHIWalkSet * walkSet, NSArray *arguments, NSDictionary *environment,  NSError **outError){
            WHIWalkSet *output = [WHIWalkSet new];
            for (WHIWalk * walk in walkSet) {
                //Unpack arguments
                //TODO: Convert these asserts to NSErrors
                NSCAssert(arguments.count == 1, @"Incorrect number of arguments. Filter expects arguments of type: [string].");
                NSString *predicateFormatString = arguments[0];
                NSCAssert([predicateFormatString isKindOfClass:[NSString class]], @"Expect NSString but found %@ .", NSStringFromClass([predicateFormatString class]));

                //Prepare predicate
                id node = walk.destinationObject;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormatString];
                NSMutableDictionary *mergedEnvironment = [environment mutableCopy];

                //TODO: Should these be log statements? Would it be better to fail and set the error?
                if (mergedEnvironment[@"EDGE"] != nil) {
                    NSLog(@"Environment dictionary already contains a value for EDGE. This value will be overwritten when evaluating filter predicate.");
                }

                switch (objectTypeOfObject(node)) {
                    case WHIFunctionObjectTypeKeyedCollection:
                    case WHIFunctionObjectTypeArbitaryObject:
                        for (NSString *key in allKeysInObject(node)) {
                            id value = [node valueForKey:key];
                            WHIWalk *edge = [[WHIWalk alloc] initWithDestinationObject:value label:key preceedingWalk:walk];
                            mergedEnvironment[@"EDGE"] = edge;
                            BOOL isMatch = [predicate evaluateWithObject:node substitutionVariables:mergedEnvironment];
                            if (isMatch) [output addWalk:edge];
                        }
                        break;

                    case WHIFunctionObjectTypeIndexedCollection: {
                        NSInteger idx = 0;
                        for (id value in node) {
                            WHIWalk *edge = [[WHIWalk alloc] initWithDestinationObject:value label:@(idx) preceedingWalk:walk];
                            mergedEnvironment[@"EDGE"] = edge;
                            BOOL isMatch = [predicate evaluateWithObject:node substitutionVariables:mergedEnvironment];
                            if (isMatch) [output addWalk:edge];
                            idx++;
                        }

                        break;
                    }
                }
            }
            return output;
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
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(WHIWalkSet * walkSet, NSArray *arguments, NSDictionary *environment, NSError **outError){
            return walkSet;
        })];
    });
    return function;
}



+(WHIFunction *)emptySetFunction
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(WHIWalkSet * walkSet, NSArray *arguments, NSDictionary *environment, NSError **outError){
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
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(WHIWalkSet * walkSet, NSArray *arguments, NSDictionary *environment, NSError **outError){
            if (outError != NULL) *outError = [NSError errorWithDomain:WHIWhittleErrorDomain code:0 userInfo:nil];
            return nil;
        })];
    });
    return function;

}

@end
