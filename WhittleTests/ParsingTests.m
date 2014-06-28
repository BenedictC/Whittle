//
//  ParsingTests.m
//  Whittle
//
//  Created by Benedict Cohen on 21/10/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WHIWhittle.h"
#import "WHIInvocation.h"



@interface ParsingTests : XCTestCase
@end



@implementation ParsingTests

-(void)testInvocationEquivilance
{
    WHIInvocation *expectedResult = [[WHIInvocation alloc] initWithFunctionName:@"arf" arguments:@[]];
    WHIInvocation *actualResult = [[WHIInvocation alloc] initWithFunctionName:@"arf" arguments:@[]];

    XCTAssertEqualObjects(expectedResult, actualResult, @"Invocation not equal.");
}



-(void)testVaildOperationWithZeroOperands
{
    WHIInvocation *expectedResult = [[WHIInvocation alloc] initWithFunctionName:@"validFunction" arguments:@[]];
    WHIInvocation *actualResult = [[[WHIWhittle whittleWithQuery:@"(validFunction)"] invocations] firstObject];

    XCTAssertEqualObjects(expectedResult, actualResult, @"expect result does not match actual result.");
}



-(void)testInvaildOperationWithZeroOperands
{
    WHIInvocation *expectedResult = nil;
    NSError *error = nil;
    WHIInvocation *actualResult = [[[WHIWhittle whittleWithQuery:@"(1invalidFunction)"] invocations] firstObject];

    XCTAssertEqualObjects(expectedResult, actualResult, @"expect result does not match actual result.");
    XCTAssertNotNil(error, @"Error not filled.");
}



@end
