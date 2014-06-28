//
//  WHIInvocation.m
//  Whittle
//
//  Created by Benedict Cohen on 02/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIInvocation.h"



@implementation WHIInvocation

#pragma mark - instance life cycle
-(id)initWithFunctionName:(NSString *)functionName arguments:(NSArray *)arguments
{
    NSParameterAssert(functionName != nil);
    NSParameterAssert(arguments != nil);
    
    self = [super init];
    if (self == nil) return nil;

    _functionName = [functionName copy];
    _arguments = [arguments copy];
    
    return self;
}



-(id)init
{
    return [self initWithFunctionName:nil arguments:nil];
}



#pragma mark - properties
-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> {functionName = %@, arguments = %@}", NSStringFromClass([self class]), self, self.functionName, [self.arguments description]];
}



#pragma mark - equality
-(BOOL)isEqual:(id)otherObject
{
    if (otherObject == nil) return NO;

    if (![otherObject isKindOfClass:[WHIInvocation class]]) return NO;

    return [self hash] == [otherObject hash];
}



-(NSUInteger)hash
{
    return [self.functionName hash] ^ [self.arguments hash];
}

@end
