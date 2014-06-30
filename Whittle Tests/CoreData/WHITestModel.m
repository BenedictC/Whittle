//
//  WHITestModel.m
//  Whittle
//
//  Created by Benedict Cohen on 19/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHITestModel.h"
#import <CoreData/CoreData.h>



@interface WHITestModel ()
@property(readonly, nonatomic) NSManagedObjectContext *mainContext;
@property(readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@end



@implementation WHITestModel

#pragma mark - default instance
+(instancetype)defaultModel
{
    static WHITestModel *defaultModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultModel = [WHITestModel new];
    });
    return defaultModel;
}



-(id)init
{
    self = [super init];
    if (self == nil) return nil;

    //TODO: Create core data stack
//    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
//    [_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:<#(NSString *)#> URL:<#(NSURL *)#> options:<#(NSDictionary *)#> error:<#(NSError *__autoreleasing *)#>
    return self;
}



-(void)initializeStoreContents
{
    //TODO:
}



-(NSManagedObject *)rootCollection
{
    //TODO:
    return nil;
}

@end
