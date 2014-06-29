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
 WHIWhittle is responsible for executing an array of WHIInvocations by looking up the function in
 environment. WHIWhittle is NOT responsible for creating the invocation array. The creation of the
 invocation list is handled by the DSLFactory category of WHIWhittle.


 ## Whittle Queries

 Whittle queries are a series of functions. Each function takes a graph edge and
 returns a set of graph edges. The returned edges are then used as the input for the next function. The output of each
 invocation of the function are unioned and used as the input for the next function. The basic form is:

 (aFunction)(anotherFunction argument1)(a3rdFunction argument1, argument2)
 
 Functions can take any number of arguments but are limited to the follow types:
 number             Numbers are treated as doubles
 string             Back tick (`) delimited. A back tick can be escaped with a slash (/). A literal slash is //.
 invocationList     Functions take the form as described previously, i.e., (functionName argument1, argument2) etc.
 variable           Variables take the form $variableName, i.e. a dollar sign followed by string of alpha numeric
                    characters. Variables are resolved from the environment prior to function invocation.

 Functions have access to the environment dictionary.

 The function implementations are retereived from the environment dictionary when the query is execute. 
 +defaultEnvironment contains the following functions:

 root           Returns the root of the graph. 
                Parameters:
                 - None

 preceeding     Returns the preeceding node of the walk. 
                Parameters:
                 - None

 endpoints      Returns all edges that originate from the current node. 
                Parameters:
                 - None

 all            Returns all edges that accessible from the current node (a recrusive call to endpoints). 
                Parameters:
                 - None

 filter         Returns all edges that match the supplied filter. 
                Parameters:
                 1. filter: string. The filter has access to the environment. Environment can be accessed by appending 
                    a $ to the environment varible name. Additional environment variables are available: $EDGE_NAME, 
                    $EDGE_INDEX, $DESTINATION_NODE

 pick           Returns the first edge with name or index matching the supplied parameter. 
                Parameters:
                 ... A list of string/number. Returns the edges that matches the string/numbers.

 union          Returns an edge set created by combining the results of the edge sets returned by each parameter.
                Parameters:
                 ... A list of invocationLists

 Additional functions can be defined by adding instance of WHIFunction to the environment dictionary. The function can
 then be referenced by using its' dictionary key as the function name:
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

//TODO: Document the content of defaultEnvironment.
+(NSDictionary *)defaultEnvironment;

-(id)initWithInvocationList:(NSArray *)invocations defaultEnvironment:(NSDictionary *)defaultEnvironment;
@property(nonatomic, readonly) NSArray *invocations;
@property(nonatomic, readonly) NSDictionary *defaultEnvironment;

-(id)initWithInvocationList:(NSArray *)invocations; //Convinence init which uses +defaultEnvironment
/**
 Execute the invocation list against an object.

 @param rootObject the object to use as the root of the object graph that the invocation list will be executed against.
 @param environment a dictionary used to look up functions and value when the query is executed.
 @param outError an output error if the invocations could not be successfully executed. Errors can be of 2 types:
 1. Invalid function arguments. EG, a number when a string was expected.
 2. Invalid data. EG, the function expected an array but found a dictionary.

 @return The result of the query or nil if an error occured.
 */
-(id<WHIEdgeSet>)executeWithObject:(id)rootObject environment:(NSDictionary *)environment error:(NSError **)outError;

@end



@interface WHIWhittle (DSLFactory)

/**
 Creates an instance of WHIWhittle from a Whittle query string. The instance is created with +defaultEnvironment.

 @param query A whittle query. See 'Whittle Queries' for details. If query is malformed then an invalid argument 
 exception is raised.

 @return An instance of WHIWhittle for the given query.
 */
+(instancetype)whittleWithQuery:(NSString *)query;

@end



@interface NSObject (Whittle)

/**
 Convience method for creating and executing a WHIWhittle instance. This method is equivilent to create a WHIWhittle
 instances with whittleWithQuery: and then calling executeWithObject:environment:error: were object is the receiver.

 @param query A whittle query. See 'Whittle Queries' for details. If query is malformed then an invalid argument
 exception is raised.
 @param environment a dictionary used to look up functions and value when the query is executed.
 @param outError an output error if the invocations could not be successfully executed. Errors can be of 2 types:
    1. Invalid function arguments. EG, a number when a string was expected.
    2. Invalid data. EG, the function expected an array but found a dictionary.

 @return The result of the query or nil if an error occured.
 */
-(id<WHIEdgeSet>)WHI_evaluateQuery:(NSString *)query environment:(NSDictionary *)environment error:(NSError **)outError;

/**
 This is equivilent to calling WHI_evaluateQuery:environment:error: with an empty environment dictionary and a NULL outError.

 @param query A Whittle query.

 @return The result of the query.
 */
-(id<WHIEdgeSet>)WHI_evaluateQuery:(NSString *)query;

@end
