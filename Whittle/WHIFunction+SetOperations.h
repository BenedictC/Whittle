//
//  WHIFunction+SetOperations.h
//  Whittle
//
//  Created by Benedict Cohen on 28/06/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import "WHIFunction.h"

/**
 Set operations are in a seperate category and not in WHIFunction as they depend on WHIInvocation. We want to avoid
 tightly coupling WHIFunction and WHIInvocation.
 */


@interface WHIFunction (SetOperations)

+(WHIFunction *)unionOperation;          //Returns the union of two nodeSets.
//TODO: +(WHIFunction *)minusOperation;       //Returns a set with the objects of the query removed from the receiver/
//TODO: +(WHIFunction *)intersectOperation;

@end
