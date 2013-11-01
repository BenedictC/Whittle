//
//  WHIPath.m
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIPath.h"



@implementation WHIPath

#pragma mark - instance life cycle
-(id)initWithDestinationObject:(id)object preceedingPath:(id<WHIPath>)preceedingPath userInfo:(NSDictionary *)userInfo
{
    NSAssert(preceedingPath == nil || [preceedingPath conformsToProtocol:@protocol(WHIPath)], @"preceedingPath does not conform to WHIPath");
    
    self = [super init];
    if (self == nil) return nil;
    
    _destinationObject = object;
    _preceedingPath = preceedingPath;
    _userInfo = [userInfo copy];
    
    return self;
}



#pragma mark - properties
-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> destinationObject:<%@> preceedingPath:<%@ %p> userInfo:<%@>", NSStringFromClass([self class]), self, self.destinationObject, [self.preceedingPath class], self.preceedingPath, self.userInfo];
}



#pragma mark - equality
-(NSUInteger)hash
{
    return [self.destinationObject hash] ^ [self.preceedingPath hash] ^ [self.userInfo hash];
}

@end

