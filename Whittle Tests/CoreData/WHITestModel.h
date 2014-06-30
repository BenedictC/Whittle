//
//  WHITestModel.h
//  Whittle
//
//  Created by Benedict Cohen on 19/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "WHTCollection.h"
#import "WHTElement.h"



@interface WHITestModel : NSObject

+(instancetype)defaultModel;
-(NSManagedObject *)rootCollection;

@end

