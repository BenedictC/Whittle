//
//  ParsingTests.m
//  Whittle
//
//  Created by Benedict Cohen on 21/10/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "WHIWhittle.h"
#import "WHIInvocation.h"



@interface ParsingTests : SenTestCase
@end



@implementation ParsingTests

-(void)testInvocationEquivilance
{
    WHIInvocation *expectedResult = [[WHIInvocation alloc] initWithFunctionName:@"arf" arguments:@[]];
    WHIInvocation *actualResult = [[WHIInvocation alloc] initWithFunctionName:@"arf" arguments:@[]];

    STAssertEqualObjects(expectedResult, actualResult, @"Invocation not equal.");
}



-(void)testVaildOperationWithZeroOperands
{
    WHIInvocation *expectedResult = [[WHIInvocation alloc] initWithFunctionName:@"validFunction" arguments:@[]];
    WHIInvocation *actualResult = [[[[WHIWhittle alloc] initWithPath:@"(validFunction)" error:NULL] invocations] firstObject];

    STAssertEqualObjects(expectedResult, actualResult, @"expect result does not match actual result.");
}



-(void)testInvaildOperationWithZeroOperands
{
    WHIInvocation *expectedResult = nil;
    NSError *error = nil;
    WHIInvocation *actualResult = [[[[WHIWhittle alloc] initWithPath:@"(1invalidFunction)" error:&error] invocations] firstObject];

    STAssertEqualObjects(expectedResult, actualResult, @"expect result does not match actual result.");
    STAssertNotNil(error, @"Error not filled.");
}



@end
