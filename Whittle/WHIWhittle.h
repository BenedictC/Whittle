//
//  WHIWhittle.h
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WHIEdgeProtocols.h"



/*
 WHIInvocationChainEvaluator is responsible for executing an array of WHIInvocations by looking up the function in
 bindings. WHIInvocationChainEvaluator is NOT responsible for creating the invocation array. The creation of the
 invocation array is handled by a subclass of WHIInvocationChainEvaluator, namely WHIWhittle.


 ## Whittle Queries

 Whittle queries are a series of functions. Each function takes a graph edge and
 returns a set of graph edges. The returned edges are then used as the input for the next function. The output of each
 invocation of the function are unioned and used as the input for the next function. The basic form is:

 (aFunction)(anotherFunction argument1)(a3rdFunction argument1, argument2)
 
 Functions can take any number of arguments but are limited to the follow types:
 number:        Numbers are treated as doubles
 string:        Back tick (`) delimited. A back tick can be escaped with a slash (/). A literal slash is //.
 function:      Functions take the form as described previously, i.e., (functionName argument1, argument2) etc.
 //TODO: variable:      Is this sensible? When would the value be resolved?

 Functions have access to the bindings dictionary.

 The function implementations are retereived from the bindings dictionary when the query is execute. +defaultBindings
 contains the following functions:

 @"root":       Returns the root of the graph. Parameters:
                 - None
 @"preceeding": Returns the preeceding node of the walk. Parameters:
                 - None

 @"endpoints":  Returns all edges that originate from the current node. Parameters:
                 - None
 @"all":        Returns all edges that accessible from the current node (a recrusive call to endpoints). Parameters:
                 - None
 @"filter":     Returns all edges that match the supplied filter. Parameters:
                 1. filter: string. The filter has access to the bindings. Bindings can be accessed by appending a $ to
                   the binding name. Additional bindings are available: $EDGE_NAME, $EDGE_INDEX, $DESTINATION_NODE
 @"pick":       Returns the first edge with name or index matching the supplied parameter:
                 1. id: string/number. Returns the edge that matches the id.
                //TODO: Allow this to be a list

 @"union":      [WHIFunction unionOperation],


 A concrete example:
 (pick `events`)(filter `$VALUE.date > $date`)

 Additional Functions can be defined by adding instance of WHIFunction to the bindings dictionary. The function can then
 be referenced by using its' dictionary key as the function name:
 (pick `results`)(odd)
 
 See WHIFunction for details of creating functions.

 
////TODO: Implement these!!!
// In addition to the basic form there some functions have syntactic sugar:
// 
//
//
// ~      root       //Returns the first node in the path.
// ..     preceeding //Returns the preceeding node in the path.
//
//
// ?      endpoints  //Returns all endpoint nodes for the current node.
// *      all        //Returns all nodes in the sub graph.
//
// [INTEGER|STRING] pick //TODO: We need a way to specify strings that only contain numerals and escape sequences.
// [?FILTER_STRING]
//
//Combining path sets
//-------------------
// path | path
//unionOperation;          //Returns the union of two nodeSets

 */



@interface WHIWhittle : NSObject

//TODO: Document the content of defaultBindings.
+(NSDictionary *)defaultBindings;

-(id)initWithInvocationChain:(NSArray *)invocations defaultBindings:(NSDictionary *)defaultBindings;
@property(nonatomic, readonly) NSArray *invocations;
@property(nonatomic, readonly) NSDictionary *defaultBindings;

-(id)initWithInvocationChain:(NSArray *)invocations; //Convinence init which uses +defaultBindings
/**
 Execute the invocation chain against an object.

 @param rootObject the object to use as the root of the object graph that the invocation chain will be executed against.
 @param bindings a dictionary used to look up functions and value when the query is executed.
 @param outError an output error if the invocations could not be successfully executed. Errors can be of 2 types:
 1. Invalid function arguments. EG, a number when a string was expected.
 2. Invalid data. EG, the function expected an array but found a dictionary.

 @return The result of the query or nil if an error occured.
 */
-(id<WHIEdgeSet>)executeWithObject:(id)rootObject bindings:(NSDictionary *)bindings error:(NSError **)outError;

@end



@interface WHIWhittle (DSLFactory)

/**
 Creates an instance of WHIWhittle from a Whittle query string. The instance is created with +defaultBindings.

 @param query A whittle query. See 'Whittle Queries' for details. If query is malformed then an invalid argument 
 exception is raised.

 @return An instance of WHIWhittle for the given query.
 */
+(instancetype)whittleWithQuery:(NSString *)query;

@end



@interface NSObject (Whittle)

/**
 Convience method for creating and executing a WHIWhittle instance. This method is equivilent to create a WHIWhittle
 instances with whittleWithQuery: and then calling executeWithObject:bindings:error: were object is the receiver.

 @param query A whittle query. See 'Whittle Queries' for details. If query is malformed then an invalid argument
 exception is raised.
 @param bindings a dictionary used to look up functions and value when the query is executed.
 @param outError an output error if the invocations could not be successfully executed. Errors can be of 2 types:
    1. Invalid function arguments. EG, a number when a string was expected.
    2. Invalid data. EG, the function expected an array but found a dictionary.

 @return The result of the query or nil if an error occured.
 */
-(id<WHIEdgeSet>)WHI_evaluateQuery:(NSString *)query bindings:(NSDictionary *)bindings error:(NSError **)outError;

/**
 This is equivilent to calling WHI_evaluateQuery:bindings:error: with an empty bindings dictionary and a NULL outError.

 @param query A Whittle query.

 @return The result of the query.
 */
-(id<WHIEdgeSet>)WHI_evaluateQuery:(NSString *)query;

@end
