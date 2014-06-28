//
//  WHIEdgeSet.h
//  Whittle
//
//  Created by Benedict Cohen on 05/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHIEdgeProtocols.h"



/*

 TODO: Document WHIEdgeSet.

 */

@interface WHIEdgeSet : NSObject <WHIEdgeSet>

//Factory methods
+(instancetype)edgeSetWithEdgeToDestinationObject:(id)object preceedingEdge:(id<WHIEdge>)preceedingEdge userInfo:(NSDictionary *)userInfo;
+(instancetype)edgeSetWithEdge:(id<WHIEdge>)edge;

//Creation
-(id)initWithEdgeToDestinationObject:(id)object preceedingEdge:(id<WHIEdge>)preceedingEdge userInfo:(NSDictionary *)userInfo;
-(id)initWithEdge:(id<WHIEdge>)edge; //Designated init

//Adding edges
-(void)addEdge:(id<WHIEdge>)edge;
-(void)addEdgeToDestinationObject:(id)object preceedingEdge:(id<WHIEdge>)preceedingEdge userInfo:(NSDictionary *)userInfo;
-(void)addEdgesFromEdgeSet:(id<WHIEdgeSet>)edgeSet;

@end
