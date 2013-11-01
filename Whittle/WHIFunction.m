//
//  WHIFunction.m
//  Whittle
//
//  Created by Benedict Cohen on 08/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIFunction.h"



@implementation WHIFunction

#pragma mark - factory
+(instancetype)functionWithBlock:(id)block
{
    return [[self alloc] initWithBlock:block];
}



#pragma mark - instance life cycle
-(id)initWithBlock:(id)block
{
    self = [super init];
    if (self == nil) return nil;
    
    _block = [block copy];
    
    return self;
}

@end
