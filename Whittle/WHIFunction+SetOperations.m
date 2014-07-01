//
//  WHIFunction+SetOperations.m
//  Whittle
//
//  Created by Benedict Cohen on 28/06/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "WHIFunction+SetOperations.h"
#import "WHIInvocation.h"
#import "WHIWalkSet.h"
#import "WHIWalk.h"



@implementation WHIFunction (SetOperations)

+(WHIFunction *)unionOperation
{
    static dispatch_once_t onceToken;
    static WHIFunction *function = nil;
    dispatch_once(&onceToken, ^{
        function = [WHIFunction functionWithBlock:(^WHIWalkSet *(WHIWalkSet *walkSet, NSArray *unionArguments, NSDictionary *environment, NSError **outError){
            WHIWalkSet *output = [WHIWalkSet new];

            for (WHIWalk *walk in walkSet) {

                for (NSArray *invocationList in unionArguments) {
                    WHIWalkSet *rootWalkSet = [WHIWalkSet walkSetWithWalk:walk];
                    WHIWalkSet *childWalkSet = [WHIInvocation executeInvocationList:invocationList edgeSet:rootWalkSet environment:environment error:outError];
                    BOOL didError = (childWalkSet == nil);
                    if (didError) return nil;

                    [output addWalksFromWalkSet:childWalkSet];
                }
            }
            return output;
        })];
    });
    return function;

}

//TODO: +(WHIFunction *)minusOperation;       //Returns a set with the objects of the query removed from the receiver/
//TODO: +(WHIFunction *)intersectOperation;

@end
