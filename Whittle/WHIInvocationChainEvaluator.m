//
//  WHIInvocationChainEvaluator.m
//  Whittle
//
//  Created by Benedict Cohen on 26/07/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIInvocationChainEvaluator.h"

#import "WHIPathSet.h"
#import "WHIInvocation.h"
#import "WHIFunction+WHIPathOperation.h"



#pragma mark - whittle implementation
@implementation WHIInvocationChainEvaluator

+(NSDictionary *)defaultBindings
{
    static NSDictionary *defaultBindings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultBindings = @{
                            @"evaluate":        [WHIFunction evaluateInvocationOperation],
                            @"evaluateChain":   [WHIFunction evaluateInvocationChainOperation],
                            @"root":            [WHIFunction rootNodeOperation],
                            @"preceeding":      [WHIFunction preceedingNodeOperation],
                            @"endpoints":       [WHIFunction endpointNodesOperation],
                            @"all":             [WHIFunction allNodesOperation],
                            @"pick":            [WHIFunction pickOperation],
                            @"filter":          [WHIFunction filterOperation],
                            @"union":           [WHIFunction unionOperation],
                           };
      });
    
    return defaultBindings;
}



#pragma mark - instance life cycle
-(id)initWithInvocationChain:(NSArray *)invocations
{
    self = [super init];
    if (self == nil) return nil;
    
    _invocations = [invocations copy];
    
    return self;
}



#pragma mark - evaluation
-(id<WHIPathSet>)evaluateWithObject:(id)rootObject bindings:(NSDictionary *)userBindings error:(NSError **)outError
{
    //Create the bindings
    NSMutableDictionary *mergedBindings = [[WHIInvocationChainEvaluator defaultBindings] mutableCopy];
    if (userBindings != nil) [mergedBindings addEntriesFromDictionary:userBindings];
        
    //Evaluate
    WHIFunction *evaluateChain = mergedBindings[@"evaluateChain"];
    NSArray *arguments = @[rootObject, self.invocations];
    return [evaluateChain invokePathOperationWithPath:nil arguments:arguments bindings:mergedBindings error:outError];
}

@end
