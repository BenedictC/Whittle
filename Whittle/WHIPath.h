//
//  WHIPath.h
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHIPathProtocols.h"



/*

 TODO: Document WHIPath.

 */

@interface WHIPath : NSObject <WHIPath>

-(id)initWithDestinationObject:(id)object preceedingPath:(id<WHIPath>)preceedingPath userInfo:(NSDictionary *)userInfo;
@property(nonatomic, readonly) id destinationObject;
@property(nonatomic, readonly) id<WHIPath> preceedingPath;
@property(nonatomic, readonly) NSDictionary *userInfo;
@end
