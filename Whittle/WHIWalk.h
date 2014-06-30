//
//  WHIWalk.h
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHIWalkProtocols.h"



/*

 TODO: Document WHIWalk.

 */

@interface WHIWalk : NSObject <WHIWalk>

-(id)initWithDestinationObject:(id)object label:(id)label preceedingWalk:(id<WHIWalk>)preceedingWalk;
@property(nonatomic, readonly) id destinationObject;
@property(nonatomic, readonly) id label;
@property(nonatomic, readonly) id<WHIWalk> preceedingWalk;

@end
