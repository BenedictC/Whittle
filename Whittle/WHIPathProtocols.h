//
//  WHIPathProtocols.h
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>



/*

 TODO: Document WHIPath.

 */

@protocol WHIPath <NSObject>

-(id)destinationObject;
-(id<WHIPath>)preceedingPath;
-(NSDictionary *)userInfo;

@end



/*

 TODO: Document WHIPathSet.

 */

@protocol WHIPathSet <NSObject, NSFastEnumeration>

-(NSArray *)paths;
-(NSArray *)objects;
-(id)lastObject;

@end
