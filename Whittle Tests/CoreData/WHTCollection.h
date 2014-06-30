//
//  WHTCollection.h
//  Whittle
//
//  Created by Benedict Cohen on 03/09/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WHTElement;

@interface WHTCollection : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) WHTElement *elements;

@end
