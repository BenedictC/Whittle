//
//  WHIWhittle.h
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIInvocationChainEvaluator.h"



//Navigating up the path
//----------------------
// ~
//rootNodeOperation;       //Returns the first node in the path.
// ..
//preceedingNodeOperation; //Returns the preceeding node in the path.

//Navigating down the path
//------------------------
// ?
//endpointNodesOperation;  //Returns all endpoint nodes for the current node. (identical to  calling filter with format "TRUEPREDICATE")
// *
//allNodesOperation;       //Returns all nodes in the sub graph.
// pickArgument
//pickOperation;           //Returns the first object with key/index that exactly matches a collection.
// [filterString]
//filterOperation;         //Returns all objects that match the predicate.

//Combining path sets
//-------------------
// path | path
//unionOperation;          //Returns the union of two nodeSets




@interface WHIWhittle : WHIInvocationChainEvaluator

-(id)initWithPath:(NSString *)path error:(NSError **)outError;

@end



//@interface NSObject (Whittle)
//-(id<WHIPathSet>)WHI_evaluatePath:(NSString *)path bindings:(NSDictionary *)bindings error:(NSError **)outError;
//-(id<WHIPathSet>)WHI_evaluatePath:(NSString *)path;
//@end
