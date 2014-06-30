//
//  WHIWalkProtocols.h
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>



/*

 TODO: Document WHIWalk.

 */

@protocol WHIWalk <NSObject>

-(id)destinationObject;
-(id<WHIWalk>)preceedingWalk;
-(id)label;

@end



/*

 TODO: Document WHIWalkSet.

 */

@protocol WHIWalkSet <NSObject, NSFastEnumeration>

-(NSSet *)walks;

-(NSSet *)objects; //Destinations of the edges

@end
