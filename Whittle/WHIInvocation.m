//
//  WHIInvocation.m
//  Whittle
//
//  Created by Benedict Cohen on 02/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIInvocation.h"
#import "WHIFunction.h"
#import "WHIWalkSet.h"
#import "WHIError.h"



@implementation WHIInvocationVariableArgument

-(instancetype)initWithVariableName:(NSString *)variableName
{
    self = [super init];
    if (self == nil) return nil;
    _variableName = [variableName copy];
    return self;
}

@end



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
-(id<WHIWalkSet>)invokeWithWalkSet:(id<WHIWalkSet>)inputWalkSet environment:(NSDictionary *)environment error:(NSError **)outError
{
    //Resolve variable
    NSMutableArray *resolvedArguments = [NSMutableArray new];
    for (id argument in self.arguments) {
        BOOL isVariable = [argument isKindOfClass:[WHIInvocationVariableArgument class]];
        id value = (isVariable) ? environment[[argument variableName]] : argument;
        if (value == nil) {
            //TODO: Unable to resolve variable
            if (outError != NULL) *outError = [NSError errorWithDomain:WHIWhittleErrorDomain code:0 userInfo:nil];
            return nil;
        }
        [resolvedArguments addObject:value];
    }

    //Resolve and execute the function
    WHIFunction *function = environment[self.functionName];
    if (function == NULL) {
        NSString *description = [NSString stringWithFormat:@"Function not found for binding named %@", self.functionName];
        if (outError != NULL) *outError = [NSError errorWithDomain:WHIWhittleErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: description}];
        return nil;
    }
    return [function executeWithWalk:inputWalkSet arguments:resolvedArguments environment:environment error:outError];
}



#pragma mark - invocation list
+(id<WHIWalkSet>)executeInvocationList:(NSArray *)invocations edgeSet:(id<WHIWalkSet>)inputWalkSet environment:(NSDictionary *)environment error:(NSError **)outError
{
    //Invoke the function on every object return by the previous function.
    WHIWalkSet *preceedingWalkSet = inputWalkSet;
    for (WHIInvocation *invocation in invocations) {

        WHIWalkSet *currentWalkSet = [invocation invokeWithWalkSet:preceedingWalkSet environment:environment error:outError];
        BOOL didError = (currentWalkSet == nil);
        if (didError) return nil;

        //Prep for the next invocation
        preceedingWalkSet = currentWalkSet;
    }

    return preceedingWalkSet;
}

@end



