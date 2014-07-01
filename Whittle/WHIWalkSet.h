//
//  WHIWalkSet.h
//  Whittle
//
//  Created by Benedict Cohen on 05/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WHIWalk;
@class WHIWalkSet;



/*

 TODO: Document WHIWalkSet.

 */

@interface WHIWalkSet : NSObject <NSFastEnumeration>
//Factory methods
+(instancetype)walkSetWithWalkToDestinationObject:(id)object label:(id)label preceedingWalk:(WHIWalk *)preceedingWalk;
+(instancetype)walkSetWithWalk:(WHIWalk *)walk;

//Creation
-(id)initWithWalkToDestinationObject:(id)object label:(id)label preceedingWalk:(WHIWalk *)preceedingWalk;
-(id)initWithWalk:(WHIWalk *)walk; //Designated init

//Adding edges
-(void)addWalk:(WHIWalk *)walk;
-(void)addWalkToDestinationObject:(id)object label:(id)label preceedingWalk:(WHIWalk *)preceedingWalk;
-(void)addWalksFromWalkSet:(WHIWalkSet *)walkSet;

//Properties
@property(nonatomic, readonly) NSSet *walks;
@property(nonatomic, readonly) NSSet *objects;

@end
