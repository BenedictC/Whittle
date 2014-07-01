//
//  WHIWalk.m
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIWalk.h"



@implementation WHIWalk

#pragma mark - factory method
+(instancetype)walkWithDestinationObject:(id)object
{
    return [[self alloc] initWithDestinationObject:object label:nil preceedingWalk:nil];
}



+(instancetype)walkWithDestinationObject:(id)object label:(id)label preceedingWalk:(WHIWalk *)preceedingWalk
{
    return [[self alloc] initWithDestinationObject:object label:label preceedingWalk:preceedingWalk];
}



#pragma mark - instance life cycle
-(id)initWithDestinationObject:(id)object label:(id)label preceedingWalk:(WHIWalk *)preceedingWalk
{
    NSParameterAssert(object);
    NSAssert(!(label == nil ^ preceedingWalk == nil), @"Invalid label/preceedingWalk combination. If a preceedingWalk is provided then so must a label and vice versa. label = %@, preceedingWalk = %@", label, preceedingWalk);
    
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



-(id)sourceObject
{
    return self.preceedingWalk.destinationObject;
}



-(BOOL)containsCycle
{
    WHIWalk *walk = self.preceedingWalk;
    while (walk != nil) {
        if ([walk.destinationObject isEqual:self.destinationObject] && [walk.sourceObject isEqual:self.sourceObject]) return YES;
        walk = walk.preceedingWalk;
    }
    //TODO: Should recurse of self.preceedingWalk?

    return NO;
}



#pragma mark - equality
-(BOOL)isEqual:(WHIWalk *)otherWalk
{
    if (![otherWalk isKindOfClass:[WHIWalk class]]) return NO;

    BOOL (^isEqualObjects)(id object1, id object2) = ^BOOL(id object1, id object2){
        if (object1 == nil && object2 != nil) return NO;
        if (object1 != nil && object2 == nil) return NO;
        if (object1 != nil && ![object1 isEqual:object2]) return NO;

        return YES;
    };

    if (!isEqualObjects(self.destinationObject, otherWalk.destinationObject)) return NO;
    if (!isEqualObjects(self.label, otherWalk.label)) return NO;
    //We have to check the complete walk not just the final edge because the graph could contain multiple identical
    //sub-graphs. EG:
    // NSDictionary *address = @{@"city": @"London"};
    //id person1.address = address;
    //id person2.address = address;
    //
    //if we then performed:
    //(all)(filter `$EDGE_NAME` == 'address' && $VALUE.city == 'London')(preeceeding)
    //We'd only get one personas a result because `filter` would have deemed the to address matches as equal.
    if (!isEqualObjects(self.preceedingWalk,otherWalk.preceedingWalk)) return NO;

    return YES;
}



-(NSUInteger)hash
{
    return [self.destinationObject hash] ^ [self.label hash] ^ [self.preceedingWalk hash];
}

@end
