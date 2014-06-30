//
//  WHIWalk.m
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIWalk.h"



@implementation WHIWalk

#pragma mark - instance life cycle
-(id)initWithDestinationObject:(id)object label:(id)label preceedingWalk:(id<WHIWalk>)preceedingWalk
{
    NSParameterAssert(object);
    NSAssert(preceedingWalk == nil || [preceedingWalk conformsToProtocol:@protocol(WHIWalk)], @"preceedingWalk does not conform to WHIWalk");
    
    self = [super init];
    if (self == nil) return nil;
    
    _destinationObject = object;
    _label = label;
    _preceedingWalk = preceedingWalk;
    
    return self;
}



-(instancetype)init
{
    return [self initWithDestinationObject:nil label:nil preceedingWalk:nil];
}



#pragma mark - properties
-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> destinationObject:<%@>, label:<%@>, preceedingWalk:<%@ %p>",  NSStringFromClass([self class]), self, self.destinationObject, self.label, [self.preceedingWalk class], self.preceedingWalk];
}



#pragma mark - equality
-(BOOL)isEqual:(WHIWalk *)object
{
    if (![object isKindOfClass:[WHIWalk class]]) return NO;

    BOOL (^isEqualObjects)(id object1, id object2) = ^BOOL(id object1, id object2){
        if (object1 == nil && object2 != nil) return NO;
        if (object1 != nil && object2 == nil) return NO;
        if (object1 != nil && ![object1 isEqual:object2]) return NO;

        return YES;
    };

    if (!isEqualObjects(self.destinationObject, object.destinationObject)) return NO;
    if (!isEqualObjects(self.label, object.label)) return NO;
    //We have to check the complete walk not just the final edge because the graph could contain multiple identical
    //sub-graphs. EG:
    // NSDictionary *address = @{@"city": @"London"};
    //id person1.address = address;
    //id person2.address = address;
    //
    //if we then performed:
    //(all)(filter `$EDGE_NAME` == 'address' && $VALUE.city == 'London')(preeceeding)
    //We'd only get one personas a result because `filter` would have deemed the to address matches as equal.
    if (!isEqualObjects(self.preceedingWalk, object.preceedingWalk)) return NO;

    return YES;
}



-(NSUInteger)hash
{
    return [self.destinationObject hash] ^ [self.label hash] ^ [self.preceedingWalk hash];
}

@end

