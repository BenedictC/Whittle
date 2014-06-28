//
//  WHIInvocation.m
//  Whittle
//
//  Created by Benedict Cohen on 02/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIInvocation.h"
#import "WHIFunction.h"
#import "WHIEdgeSet.h"



@implementation WHIInvocation

#pragma mark - instance life cycle
-(id)initWithFunctionName:(NSString *)functionName arguments:(NSArray *)arguments
{
    NSParameterAssert(functionName != nil);
    NSParameterAssert(arguments != nil);
    
    self = [super init];
    if (self == nil) return nil;

    _functionName = [functionName copy];
    _arguments = [arguments copy];
    
    return self;
}



-(id)init
{
    return [self initWithFunctionName:nil arguments:nil];
}



#pragma mark - properties
-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> {functionName = %@, arguments = %@}", NSStringFromClass([self class]), self, self.functionName, [self.arguments description]];
}



#pragma mark - equality
-(BOOL)isEqual:(id)otherObject
{
    if (otherObject == nil) return NO;

    if (![otherObject isKindOfClass:[WHIInvocation class]]) return NO;

    return [self hash] == [otherObject hash];
}



-(NSUInteger)hash
{
    return [self.functionName hash] ^ [self.arguments hash];
}



#pragma mark - invocation
-(id<WHIEdgeSet>)invokeWithEdgeSet:(id<WHIEdgeSet>)inputEdgeSet environment:(NSDictionary *)environment error:(NSError **)outError
{
    //Resolve the references
    WHIFunction *function = environment[self.functionName];
    if (function == NULL) {
        NSString *description = [NSString stringWithFormat:@"Function not found for binding named %@", self.functionName];
        if (outError != NULL) *outError = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: description}];
        return nil;
    }

    //Create output values
    WHIEdgeSet *outputEdgeSet = [WHIEdgeSet new];
    //Apply the function to each inputEdge and sum the results
    for (id<WHIEdge> inputEdge in inputEdgeSet) {

        WHIEdgeSet *subOutputEdgeSet = [function executeWithEdge:inputEdge arguments:self.arguments environment:environment error:outError];
        BOOL didError = (subOutputEdgeSet == nil);
        if (didError) return nil;

        [outputEdgeSet addEdgesFromEdgeSet:subOutputEdgeSet];
    }

    return outputEdgeSet;
}



#pragma mark - invocation list
+(id<WHIEdgeSet>)executeInvocationList:(NSArray *)invocations edgeSet:(id<WHIEdgeSet>)inputEdgeSet environment:(NSDictionary *)environment error:(NSError **)outError
{
    //Invoke the function on every object return by the previous function.
    WHIEdgeSet *preceedingEdgeSet = inputEdgeSet;
    for (WHIInvocation *invocation in invocations) {

        WHIEdgeSet *currentEdgeSet = [invocation invokeWithEdgeSet:preceedingEdgeSet environment:environment error:outError];
        BOOL didError = (currentEdgeSet == nil);
        if (didError) return nil;

        //Prep for the next invocation
        preceedingEdgeSet = currentEdgeSet;
    }

    return preceedingEdgeSet;
}

@end



