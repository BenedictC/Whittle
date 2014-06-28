//
//  WHIEdgeProtocols.h
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>



/*

 TODO: Document WHIEdge.

 */

@protocol WHIEdge <NSObject>

-(id)destinationObject;
-(id<WHIEdge>)preceedingEdge;
-(NSDictionary *)userInfo; //TODO: What is meant to be stored in here?

@end



/*

 TODO: Document WHIEdgeSet.

 */

@protocol WHIEdgeSet <NSObject, NSFastEnumeration>

-(NSArray *)edges;

//Convienice method
-(NSArray *)objects; //Destinations of the edges
-(id)lastObject;

@end
