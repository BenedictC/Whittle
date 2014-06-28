//
//  WHIFunction+SetOperations.m
//  Whittle
//
//  Created by Benedict Cohen on 28/06/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "WHIFunction+SetOperations.h"
#import "WHIInvocation.h"
#import "WHIEdgeSet.h"



@implementation WHIFunction (SetOperations)

+(WHIFunction *)unionOperation
{
    return [WHIFunction functionWithBlock:(^WHIEdgeSet *(id<WHIEdge> edge, NSArray *unionArguments, NSDictionary *environment, NSError **outError){

        WHIEdgeSet *outputEdgeSet = [WHIEdgeSet new];

        for (NSArray *invocationList in unionArguments) {
            WHIEdgeSet *rootEdgeSet = [WHIEdgeSet edgeSetWithEdge:edge];
            WHIEdgeSet *childEdgeSet = [WHIInvocation executeInvocationList:invocationList edgeSet:rootEdgeSet environment:environment error:outError];
            BOOL didError = (childEdgeSet == nil);
            if (didError) return nil;

            [outputEdgeSet addEdgesFromEdgeSet:childEdgeSet];
        }

        return outputEdgeSet;
    })];
}

//TODO: +(WHIFunction *)minusOperation;       //Returns a set with the objects of the query removed from the receiver/
//TODO: +(WHIFunction *)intersectOperation;

@end
