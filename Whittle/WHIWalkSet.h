//
//  WHIWalkSet.h
//  Whittle
//
//  Created by Benedict Cohen on 05/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHIWalkProtocols.h"



/*

 TODO: Document WHIWalkSet.

 */

@interface WHIWalkSet : NSObject <WHIWalkSet>

//Factory methods
+(instancetype)walkSetWithWalkToDestinationObject:(id)object label:(id)label preceedingWalk:(id<WHIWalk>)preceedingWalk;
+(instancetype)walkSetWithWalk:(id<WHIWalk>)walk;

//Creation
-(id)initWithWalkToDestinationObject:(id)object label:(id)label preceedingWalk:(id<WHIWalk>)preceedingWalk;
-(id)initWithWalk:(id<WHIWalk>)walk; //Designated init

//Adding edges
-(void)addWalk:(id<WHIWalk>)walk;
-(void)addWalkToDestinationObject:(id)object label:(id)label preceedingWalk:(id<WHIWalk>)preceedingWalk;
-(void)addWalksFromWalkSet:(id<WHIWalkSet>)walkSet;

@end
