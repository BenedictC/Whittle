//
//  WHIWhittleTests.m
//  Whittle
//
//  Created by Benedict Cohen on 21/10/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WHIWhittle.h"
#import "WHIInvocation.h"



@interface WHIWhittleTests : XCTestCase
@end



@implementation WHIWhittleTests

#pragma mark - execution tests


#pragma mark - DSL tests
-(void)testVaildOperationWithZeroOperands
{
    WHIInvocation *expectedResult = [[WHIInvocation alloc] initWithFunctionName:@"validFunction" arguments:@[]];
    WHIInvocation *actualResult = [[[WHIWhittle whittleWithQuery:@"(validFunction)"] invocations] firstObject];

    XCTAssertEqualObjects(expectedResult, actualResult, @"expect result does not match actual result.");
}



-(void)testInvaildOperationWithZeroOperands
{
    XCTFail(@"TODO");
}

@end
