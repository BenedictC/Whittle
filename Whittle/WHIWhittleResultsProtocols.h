//
//  WHIWhittleResultsProtocols.h.h
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

-(id)sourceObject;
-(id)label;
-(id)destinationObject;
-(id<WHIWalk>)preceedingWalk;

@end



/*

 TODO: Document WHIWalkSet.

 */

@protocol WHIWalkSet <NSObject, NSFastEnumeration>

-(NSSet *)walks;

-(NSSet *)objects; //Destinations of the edges. Convienince method for collection .destinationObject of all .walks.

@end

