//
//  WHIPathSet.h
//  Whittle
//
//  Created by Benedict Cohen on 05/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHIPathProtocols.h"



/*

 TODO: Document WHIPathSet.

 */

@interface WHIPathSet : NSObject <WHIPathSet>

//Factory methods
+(instancetype)pathSetWithPathToDestinationObject:(id)object preceedingPath:(id<WHIPath>)preceedingPath userInfo:(NSDictionary *)userInfo;
+(instancetype)pathSetWithPath:(id<WHIPath>)path;

//Creation
-(id)initWithPathToDestinationObject:(id)object preceedingPath:(id<WHIPath>)preceedingPath userInfo:(NSDictionary *)userInfo;
-(id)initWithPath:(id<WHIPath>)path; //Designated init

//Adding paths
-(void)addPath:(id<WHIPath>)path;
-(void)addPathToDestinationObject:(id)object preceedingPath:(id<WHIPath>)preceedingPath userInfo:(NSDictionary *)userInfo;
-(void)addPathsFromPathSet:(id<WHIPathSet>)pathSet;

@end
