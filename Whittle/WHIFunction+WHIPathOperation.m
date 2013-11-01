//
//  WHIFunction+WHIPathOperation.m
//  Whittle
//
//  Created by Benedict Cohen on 17/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIFunction+WHIPathOperation.h"

#import "WHIPathSet.h"
#import "WHIInvocation.h"

#import <objc/runtime.h>



#define STATIC_FUNCTION_WITH_BLOCK(BLOCK)     \
({ \
static WHIPathOperation functionBlock = BLOCK; \
\
static dispatch_once_t onceToken; \
static WHIFunction *function; \
dispatch_once(&onceToken, ^{ \
    function = [WHIFunction functionWithBlock:functionBlock]; \
}); \
function; })



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



@implementation WHIFunction (WHIPathOperation)

#pragma mark - primative functions
+(WHIFunction *)evaluateInvocationOperation
{
    return STATIC_FUNCTION_WITH_BLOCK(^WHIPathSet *(id<WHIPath> initialPath, NSArray *arguments, NSDictionary *bindings, NSError **outError){
        //Extract the arguments
        id<WHIPathSet> inputPathSet = arguments[0];
        WHIInvocation *invocation = arguments[1];
        NSCParameterAssert(inputPathSet != nil && invocation != nil); //TODO: Replace with outError

        //Resolve the references
        WHIFunction *function = bindings[invocation.functionName];
        NSCParameterAssert(function != NULL);   //TODO: Replace with outError

        //Create output values
        WHIPathSet *outputPathSet = [WHIPathSet new];
        NSError *error;

        //Apply the function to each path in the pathSet
        for (id<WHIPath> path in inputPathSet) {

            WHIPathSet *subPathSet = [function invokePathOperationWithPath:path arguments:invocation.arguments bindings:bindings error:&error];
            BOOL didError = (subPathSet == nil);
            if (didError) {
                if (outError != NULL) *outError = error;
                return nil;
            }

            [outputPathSet addPathsFromPathSet:subPathSet];
        }

        return outputPathSet;
    });
}



+(WHIFunction *)evaluateInvocationChainOperation
{
    return STATIC_FUNCTION_WITH_BLOCK(^WHIPathSet *(id<WHIPath> initialPath, NSArray *chainArguments, NSDictionary *bindings, NSError **outError){
        //Extract the arguments
        id rootObject = chainArguments[0];
        NSArray *invocations = chainArguments[1];
        WHIFunction *evaluateOperation = [WHIFunction evaluateInvocationOperation];
        NSCParameterAssert(rootObject != nil && invocations != nil && evaluateOperation != nil); //TODO: Replace with outError

        //Prepare for the first invocation
        NSDictionary *userInfo = nil; //TODO:
        WHIPathSet *rootPathSet = [WHIPathSet pathSetWithPathToDestinationObject:rootObject preceedingPath:nil userInfo:userInfo];

        //Invoke the function on every object return by the previous function.
        NSMutableArray *pathSetStack = [NSMutableArray arrayWithObject:rootPathSet];
        WHIPathSet *preceedingPathSet = rootPathSet;
        for (WHIInvocation *invocation in invocations) {

            //Note that we're using a mutable array instead of @[] or arrayWithObjects: because commas confuse the pre-processor.
            NSMutableArray *invocationArguments = [NSMutableArray arrayWithObject:preceedingPathSet];
            [invocationArguments addObject:invocation];

            WHIPathSet *currentPathSet = [evaluateOperation invokePathOperationWithPath:nil arguments:invocationArguments bindings:bindings error:outError];
            BOOL didError = (currentPathSet == nil);
            if (didError) {
                //TODO: Create wrapper error for outError.
                return nil;
            }
            //TODO: Why do we store this? We never use the stack.
            [pathSetStack addObject:currentPathSet];

            //Prep for the next invocation
            preceedingPathSet = currentPathSet;
        }

        return preceedingPathSet;
    });
}



//Returns the root object
+(WHIFunction *)rootNodeOperation
{
    return STATIC_FUNCTION_WITH_BLOCK(^WHIPathSet *(id<WHIPath> initialPath, NSArray *arguments, NSDictionary *bindings, NSError **outError){

        id<WHIPath>path = initialPath;

        while (path.preceedingPath != nil) path = path.preceedingPath;
        
        return [WHIPathSet pathSetWithPath:path];
    });
}



//Returns the first parent of the current path.                
+(WHIFunction *)preceedingNodeOperation
{
    return STATIC_FUNCTION_WITH_BLOCK(^WHIPathSet *(id<WHIPath> path, NSArray *arguments, NSDictionary *bindings, NSError **outError){
        id<WHIPath> preceedingNode = path.preceedingPath;
        
        return (preceedingNode != nil) ? [WHIPathSet pathSetWithPath:preceedingNode] : [WHIPathSet new];
    });
}



//Returns all direct 'child' objects of the object
+(WHIFunction *)endpointNodesOperation
{
    return STATIC_FUNCTION_WITH_BLOCK(^WHIPathSet *(id<WHIPath> path, NSArray *arguments, NSDictionary *bindings, NSError **outError){
        id object = path.destinationObject;
        
        //Handle dictionaries and mapTables to use the proper key.
        switch (objectTypeOfObject(object)) {    
            case WHIFunctionObjectTypeKeyedCollection: {
                WHIPathSet *nodeSet = [WHIPathSet new];
                for (NSString *key in allKeysInObject(object)) {
                    id childObject = [object objectForKey:key]; //Note that we're using objectForKey: and note valueForKey:.
                    NSDictionary *userInfo = nil; //TODO:
                    [nodeSet addPathToDestinationObject:childObject preceedingPath:path userInfo:userInfo];
                }
                return nodeSet;
            }        
                
            //Handle enumerable objects. This handles other cocoa object collections (i.e. NSArray, NSSet, NSOrderedSet)
            case WHIFunctionObjectTypeIndexedCollection: {
                WHIPathSet *nodeSet = [WHIPathSet new];
                NSUInteger idx = 0;
                for (id childObject in object) {
                    NSDictionary *userInfo = nil; //TODO:                    
                    [nodeSet addPathToDestinationObject:childObject preceedingPath:path userInfo:userInfo];
                    idx++;
                }
                return nodeSet;
            }
                
            //Default to treating as an arbitary objects
            case WHIFunctionObjectTypeArbitaryObject: { 
                WHIPathSet *nodeSet = [WHIPathSet new];
                for (NSString *key in allKeysInObject(object)) {
                    id childObject = [object valueForKey:key];
                    NSDictionary *userInfo = nil; //TODO:                    
                    [nodeSet addPathToDestinationObject:childObject preceedingPath:path userInfo:userInfo];
                }
                return nodeSet;
            } 
        }
        
        NSCAssert(NO, @"Unrecognized collection type.");
        return nil;
    });
}



//Returns all nodes in the sub graph.
+(WHIFunction *)allNodesOperation
{
    return STATIC_FUNCTION_WITH_BLOCK(^WHIPathSet *(id<WHIPath> initialPath, NSArray *arguments, NSDictionary *bindings, NSError **outError){
               
        //Walk graph breadth first
        NSMutableArray *pathStack = [NSMutableArray arrayWithObject:initialPath];
        NSMutableSet *visitedNodes = [NSMutableSet setWithObject:initialPath.destinationObject];
        WHIPathSet *allPathSet = [WHIPathSet pathSetWithPath:initialPath];
        
        while ([pathStack count] > 0) {
            //dequeue a node
            id<WHIPath> currentPath = pathStack[0];
            [pathStack removeObjectAtIndex:0];
            
            //Get all the paths connected to the currentPath.node
            WHIPathSet *pathSet = [[WHIFunction endpointNodesOperation] invokePathOperationWithPath:currentPath arguments:arguments bindings:bindings error:outError];
            if (pathSet == nil) return nil; //There was an error - endpointNodesOperation will have created the error object.
            
            //Add the results to returned node set
            [allPathSet addPathsFromPathSet:pathSet];

            //Which of the tail objects do we need to walk?
            for (id<WHIPath>childPath in pathSet) {
                id connectedNode = childPath.destinationObject;
                //Do we need to walk the edges of the node
                BOOL hasAlreadyVisitedNode = [visitedNodes containsObject:connectedNode];
                if (!hasAlreadyVisitedNode) [pathStack addObject:childPath]; //To change to a depth first walk change addObject: to insert:AtIndex:0.
                
                [visitedNodes addObject:connectedNode];
            }            
        }
        
        return allPathSet;
    });
}



//Returns the first object with key/index that exactly matches a collection.
+(WHIFunction *)pickOperation
{
    return STATIC_FUNCTION_WITH_BLOCK(^WHIPathSet *(id<WHIPath> path, NSArray *arguments, NSDictionary *bindings, NSError **outError){
        id subscript = arguments[0];
        id object = path.destinationObject;        

        BOOL isNumericSubscript = [subscript isKindOfClass:[NSNumber class]];
        if (isNumericSubscript) {
            NSInteger idx = [subscript integerValue];            
            
            if ([object respondsToSelector:@selector(objectAtIndex:)]) { 
                id value = [object objectAtIndex:idx];                
                NSDictionary *userInfo = nil; //TODO:
                return [WHIPathSet pathSetWithPathToDestinationObject:value preceedingPath:path userInfo:userInfo];
            }
            
            if ([object respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
                NSInteger enumingIdx = 0;
                for (id value in object) { 
                    if (enumingIdx == idx) {
                        NSDictionary *userInfo = nil; //TODO:
                        return [WHIPathSet pathSetWithPathToDestinationObject:value preceedingPath:path userInfo:userInfo];                        
                    }
                    enumingIdx++;
                }
            }
            
        } else {
            id key = subscript;
            id value = [object valueForKey:key];
            NSDictionary *userInfo = nil; //TODO:
            return [WHIPathSet pathSetWithPathToDestinationObject:value preceedingPath:path userInfo:userInfo];
            
        }
        
        return nil;
    });
}



//Returns all objects that match the predicate.
+(WHIFunction *)filterOperation
{
    return STATIC_FUNCTION_WITH_BLOCK(^WHIPathSet *(id<WHIPath> path, NSArray *arguments, NSDictionary *bindings,  NSError **outError){
        //TODO: Convert these asserts to NSErrors
        NSCAssert(arguments.count == 1, @"Incorrect number of arguments. Filter expects arguments of type: [string].");    
        NSString *predicateFormatString = arguments[0];
        NSCAssert([predicateFormatString isKindOfClass:[NSString class]], @"Expect NSString but found %@ .", NSStringFromClass([predicateFormatString class]));        
        
        id object = path.destinationObject;                
        WHIPathSet *nodeSet = [WHIPathSet new];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormatString];
        NSMutableDictionary *mergedBindings = [bindings mutableCopy];
        //TODO: Check that KEY, INDEX & VALUE are not set in bindings.                
        
        switch (objectTypeOfObject(object)) {
            case WHIFunctionObjectTypeKeyedCollection:
            case WHIFunctionObjectTypeArbitaryObject:
                for (NSString *key in allKeysInObject(object)) {
                    //add KEY and VALUE to bindings.
                    id value = [object valueForKey:key];
                    mergedBindings[@"KEY"] = key;
                    mergedBindings[@"INDEX"] = @(-1);
                    mergedBindings[@"VALUE"] = value;
                    BOOL isMatch = [predicate evaluateWithObject:object substitutionVariables:mergedBindings];
                    NSDictionary *userInfo = nil; //TODO
                    if (isMatch) [nodeSet addPathToDestinationObject:value preceedingPath:path userInfo:userInfo];
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
                    NSDictionary *userInfo = nil; //TODO
                    if (isMatch) [nodeSet addPathToDestinationObject:value preceedingPath:path userInfo:userInfo];
                    
                    idx++;
                }
                
                break;
            }
        }
        
        return nodeSet;    
    });
}



//Returns the union of x nodeSets.
+(WHIFunction *)unionOperation
{
    return STATIC_FUNCTION_WITH_BLOCK(^WHIPathSet *(id<WHIPath> path, NSArray *unionArguments, NSDictionary *bindings, NSError **outError){
        id object = path.destinationObject;
        WHIPathSet *pathSet = [WHIPathSet new];
        WHIFunction *evaluateChainOperation = [WHIFunction evaluateInvocationChainOperation];

        //TODO: Is it wise to loop rather than expecting explicitly 2 chains?
        for (NSArray *invocationChain in unionArguments) {

            //Note that we're using a mutable array instead of @[] or arrayWithObjects: because commas confuse the pre-processor.
            NSMutableArray *arguments = [NSMutableArray arrayWithObject:object];
            [arguments addObject:invocationChain];

            WHIPathSet *childPathSet = [evaluateChainOperation invokePathOperationWithPath:nil arguments:arguments bindings:bindings error:outError];
            BOOL didError = (childPathSet == nil);
            if (didError) {
                //TODO: Create wrapper error for outError.
                return nil;
            }

            [pathSet addPathsFromPathSet:childPathSet];
        }

        return pathSet;
    });
}



#pragma mark - execution
-(id<WHIPathSet>)invokePathOperationWithPath:(id<WHIPath>)path arguments:(NSArray *)arguments bindings:(NSDictionary *)bindings error:(NSError **)outError
{
    WHIPathOperation block = self.block;

    return block(path, arguments, bindings, outError);
}

@end
