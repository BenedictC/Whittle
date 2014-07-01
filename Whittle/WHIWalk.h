//
//  WHIWalk.h
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>



/*

 TODO: Document WHIWalk.

 */

@interface WHIWalk : NSObject
+(instancetype)walkWithDestinationObject:(id)object;
+(instancetype)walkWithDestinationObject:(id)object label:(id)label preceedingWalk:(WHIWalk *)preceedingWalk;

-(id)initWithDestinationObject:(id)object label:(id)label preceedingWalk:(WHIWalk *)preceedingWalk;
@property(nonatomic, readonly, weak) id destinationObject;
@property(nonatomic, readonly) id label;
@property(nonatomic, readonly) WHIWalk *preceedingWalk;
@property(nonatomic, readonly) id sourceObject;

-(BOOL)containsCycle;

@end
