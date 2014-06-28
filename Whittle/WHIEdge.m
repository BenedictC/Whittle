//
//  WHIEdge.m
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIEdge.h"



@implementation WHIEdge

#pragma mark - instance life cycle
-(id)initWithDestinationObject:(id)object preceedingEdge:(id<WHIEdge>)preceedingEdge userInfo:(NSDictionary *)userInfo
{
    NSAssert(preceedingEdge == nil || [preceedingEdge conformsToProtocol:@protocol(WHIEdge)], @"preceedingEdge does not conform to WHIEdge");
    
    self = [super init];
    if (self == nil) return nil;
    
    _destinationObject = object;
    _preceedingEdge = preceedingEdge;
    _userInfo = [userInfo copy];
    
    return self;
}



#pragma mark - properties
-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> destinationObject:<%@> preceedingEdge:<%@ %p> userInfo:<%@>", NSStringFromClass([self class]), self, self.destinationObject, [self.preceedingEdge class], self.preceedingEdge, self.userInfo];
}



#pragma mark - equality
-(NSUInteger)hash
{
    return [self.destinationObject hash] ^ [self.preceedingEdge hash] ^ [self.userInfo hash];
}

@end

