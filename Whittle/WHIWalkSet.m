//
//  WHIWalkSet.m
//  Whittle
//
//  Created by Benedict Cohen on 05/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIWalkSet.h"
#import "WHIWalk.h"



@interface WHIWalkSet ()
@property(nonatomic, readonly) NSMutableSet *mutableWalks;
@end



@implementation WHIWalkSet

#pragma mark - factory methods
+(instancetype)walkSetWithWalkToDestinationObject:(id)object label:(id)label preceedingWalk:(id<WHIWalk>)preceedingWalk
{
    return [[self alloc] initWithWalkToDestinationObject:object label:label preceedingWalk:preceedingWalk];
}



+(instancetype)walkSetWithWalk:(id<WHIWalk>)edge
{
    return [[self alloc] initWithWalk:edge];
}



#pragma mark - instance life cycle
-(id)initWithWalk:(id<WHIWalk>)edge //designated init
{
    self = [super init];
    if (self == nil) return nil;
    
    _mutableWalks = [NSMutableSet new];
    if (edge != nil) [_mutableWalks addObject:edge];
    
    return self;    
}



-(id)initWithWalkToDestinationObject:(id)object label:(id)label preceedingWalk:(id<WHIWalk>)preceedingWalk
{
    WHIWalk *edge = [[WHIWalk alloc] initWithDestinationObject:object label:label preceedingWalk:preceedingWalk];
    return [self initWithWalk:edge];
}



-(id)init
{
    return [self initWithWalk:nil];        
}



#pragma mark - properties
-(NSSet *)walks
{
    return [self.mutableWalks copy];
}



-(NSSet *)objects
{
    return [NSSet setWithArray:[self.mutableWalks valueForKeyPath:@"@distinctUnionOfObjects.destinationObject"]];
}



-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@> edges: %p", NSStringFromClass([self class]), self.mutableWalks];
}



#pragma mark - fast enumeration
-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.mutableWalks countByEnumeratingWithState:state objects:buffer count:len];
}



#pragma mark - adding notes
-(void)addWalkToDestinationObject:(id)object label:(id)label preceedingWalk:(id<WHIWalk>)preceedingWalk
{
    WHIWalk *walk = [[WHIWalk alloc] initWithDestinationObject:object label:label preceedingWalk:preceedingWalk];
    [self addWalk:walk];
}



-(void)addWalk:(id<WHIWalk>)walk
{
    [self.mutableWalks addObject:walk];
}



-(void)addWalksFromWalkSet:(id<WHIWalkSet>)walkSet
{
    NSSet *walks = ([walkSet isKindOfClass:[WHIWalkSet class]]) ? [(WHIWalkSet *)walkSet mutableWalks] : walkSet.walks;
    
    [self.mutableWalks addObjectsFromArray:walks.allObjects];
}

@end
