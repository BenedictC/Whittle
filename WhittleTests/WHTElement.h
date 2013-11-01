//
//  WHTElement.h
//  Whittle
//
//  Created by Benedict Cohen on 03/09/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHTCollection;

@interface WHTElement : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) WHTCollection *collection;

@end
