//
//  WHIEdge.h
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHIEdgeProtocols.h"



/*

 TODO: Document WHIEdge.

 */

@interface WHIEdge : NSObject <WHIEdge>

-(id)initWithDestinationObject:(id)object preceedingEdge:(id<WHIEdge>)preceedingEdge userInfo:(NSDictionary *)userInfo;
@property(nonatomic, readonly) id destinationObject;
@property(nonatomic, readonly) id<WHIEdge> preceedingEdge;
@property(nonatomic, readonly) NSDictionary *userInfo;

@end
