//
//  WHIFunction+WHIPathOperation.h
//  Whittle
//
//  Created by Benedict Cohen on 17/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIFunction.h"
#import "WHIPathProtocols.h"



typedef id<WHIPathSet> (^WHIPathOperation)(id<WHIPath> path, NSArray *arguments, NSDictionary *bindings, NSError **error);



@interface WHIFunction (WHIPathOperation)

//Evaluating invocations
+(WHIFunction *)evaluateInvocationChainOperation;
+(WHIFunction *)evaluateInvocationOperation;



//Navigating up the path
+(WHIFunction *)rootNodeOperation;       //Returns the first node in the path.
+(WHIFunction *)preceedingNodeOperation; //Returns the preceeding node in the path.

//Navigating down the path
+(WHIFunction *)endpointNodesOperation;  //Returns all nodes connected to the current node (identical to  calling filter with format "TRUEPREDICATE").
+(WHIFunction *)allNodesOperation;       //Returns all nodes in the sub graph.
+(WHIFunction *)pickOperation;           //Returns the first object with key/index that exactly matches a collection.
+(WHIFunction *)filterOperation;         //Returns all objects that match the predicate.

//Combining path sets
+(WHIFunction *)unionOperation;          //Returns the union of two nodeSets.

//Performing WHIPathOperation
-(id<WHIPathSet>)invokePathOperationWithPath:(id<WHIPath>)path arguments:(NSArray *)arguments bindings:(NSDictionary *)bindings error:(NSError **)outError;

@end
