//
//  WHIPathSet.m
//  Whittle
//
//  Created by Benedict Cohen on 05/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIPathSet.h"
#import "WHIPath.h"



@interface WHIPathSet ()
@property(nonatomic, readonly) NSMutableArray *mutablePaths;
@end



@implementation WHIPathSet

#pragma mark - factory methods
+(instancetype)pathSetWithPathToDestinationObject:(id)object preceedingPath:(id<WHIPath>)preceedingPath userInfo:(NSDictionary *)userInfo
{
    return [[self alloc] initWithPathToDestinationObject:object preceedingPath:preceedingPath userInfo:userInfo];
}



+(instancetype)pathSetWithPath:(id<WHIPath>)path
{
    //Cast is to silence eroneous warning.
    return [(WHIPathSet *)[self alloc] initWithPath:path];
}



#pragma mark - instance life cycle
-(id)initWithPath:(id<WHIPath>)path //designated init
{
    self = [super init];
    if (self == nil) return nil;
    
    _mutablePaths = [NSMutableArray new];
    if (path != nil) [_mutablePaths addObject:path];
    
    return self;    
}



-(id)initWithPathToDestinationObject:(id)object preceedingPath:(id<WHIPath>)preceedingPath  userInfo:(NSDictionary *)userInfo
{
    WHIPath *path = [[WHIPath alloc] initWithDestinationObject:object preceedingPath:preceedingPath userInfo:userInfo];
    return [self initWithPath:path];
}



-(id)init
{
    return [self initWithPath:nil];        
}



#pragma mark - properties
-(NSArray *)paths
{
    return [self.mutablePaths copy];
}



-(NSArray *)objects
{
    return [self.mutablePaths valueForKeyPath:@"@unionOfObjects.destinationObject"];
}



-(id)lastObject
{
    return [[self.mutablePaths lastObject] destinationObject];
}



-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@> paths: %p", NSStringFromClass([self class]), self.mutablePaths];
}



#pragma mark - fast enumeration
-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.mutablePaths countByEnumeratingWithState:state objects:buffer count:len];
}



#pragma mark - adding notes
-(void)addPathToDestinationObject:(id)object preceedingPath:(id<WHIPath>)preceedingPath  userInfo:(NSDictionary *)userInfo
{
    WHIPath *path = [[WHIPath alloc] initWithDestinationObject:object preceedingPath:preceedingPath  userInfo:userInfo];
    [self addPath:path];
}



-(void)addPath:(id<WHIPath>)path
{
    [self.mutablePaths addObject:path];
}



-(void)addPathsFromPathSet:(id<WHIPathSet>)pathSet
{
    NSArray *paths = ([pathSet isKindOfClass:[WHIPathSet class]]) ? [(WHIPathSet *)pathSet mutablePaths] : pathSet.paths;
    
    [self.mutablePaths addObjectsFromArray:paths];
}

@end
