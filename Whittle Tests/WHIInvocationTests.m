//
//  WHIInvocationTests.m
//  Whittle
//
//  Created by Benedict Cohen on 29/06/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WHIInvocation.h"



@interface WHIInvocationTests : XCTestCase

@end



@implementation WHIInvocationTests


-(void)testInvocationEquivilance
{
    WHIInvocation *expectedResult = [[WHIInvocation alloc] initWithFunctionName:@"arf" arguments:@[]];
    WHIInvocation *actualResult = [[WHIInvocation alloc] initWithFunctionName:@"arf" arguments:@[]];

    XCTAssertEqualObjects(expectedResult, actualResult, @"Invocation not equal.");
}




-(void)testVariableSubstitution
{
    XCTFail(@"TODO");
}

@end
