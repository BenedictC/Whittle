//
//  WHIEdgeSet.m
//  Whittle
//
//  Created by Benedict Cohen on 05/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIEdgeSet.h"
#import "WHIEdge.h"



@interface WHIEdgeSet ()
@property(nonatomic, readonly) NSMutableArray *mutableEdges;
@end



@implementation WHIEdgeSet

#pragma mark - factory methods
+(instancetype)edgeSetWithEdgeToDestinationObject:(id)object preceedingEdge:(id<WHIEdge>)preceedingEdge userInfo:(NSDictionary *)userInfo
{
    return [[self alloc] initWithEdgeToDestinationObject:object preceedingEdge:preceedingEdge userInfo:userInfo];
}



+(instancetype)edgeSetWithEdge:(id<WHIEdge>)edge
{
    //Cast is to silence eroneous warning.
    return [(WHIEdgeSet *)[self alloc] initWithEdge:edge];
}



#pragma mark - instance life cycle
-(id)initWithEdge:(id<WHIEdge>)edge //designated init
{
    self = [super init];
    if (self == nil) return nil;
    
    _mutableEdges = [NSMutableArray new];
    if (edge != nil) [_mutableEdges addObject:edge];
    
    return self;    
}



-(id)initWithEdgeToDestinationObject:(id)object preceedingEdge:(id<WHIEdge>)preceedingEdge  userInfo:(NSDictionary *)userInfo
{
    WHIEdge *edge = [[WHIEdge alloc] initWithDestinationObject:object preceedingEdge:preceedingEdge userInfo:userInfo];
    return [self initWithEdge:edge];
}



-(id)init
{
    return [self initWithEdge:nil];        
}



#pragma mark - properties
-(NSArray *)edges
{
    return [self.mutableEdges copy];
}



-(NSArray *)objects
{
    return [self.mutableEdges valueForKeyPath:@"@unionOfObjects.destinationObject"];
}



-(id)lastObject
{
    return [[self.mutableEdges lastObject] destinationObject];
}



-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@> edges: %p", NSStringFromClass([self class]), self.mutableEdges];
}



#pragma mark - fast enumeration
-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.mutableEdges countByEnumeratingWithState:state objects:buffer count:len];
}



#pragma mark - adding notes
-(void)addEdgeToDestinationObject:(id)object preceedingEdge:(id<WHIEdge>)preceedingEdge  userInfo:(NSDictionary *)userInfo
{
    WHIEdge *edge = [[WHIEdge alloc] initWithDestinationObject:object preceedingEdge:preceedingEdge  userInfo:userInfo];
    [self addEdge:edge];
}



-(void)addEdge:(id<WHIEdge>)edge
{
    [self.mutableEdges addObject:edge];
}



-(void)addEdgesFromEdgeSet:(id<WHIEdgeSet>)edgeSet
{
    NSArray *edges = ([edgeSet isKindOfClass:[WHIEdgeSet class]]) ? [(WHIEdgeSet *)edgeSet mutableEdges] : edgeSet.edges;
    
    [self.mutableEdges addObjectsFromArray:edges];
}

@end
