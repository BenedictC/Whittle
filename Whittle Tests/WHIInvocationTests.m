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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    id expectedResult = [json WHI_evaluateQuery:@"(all)(filter `$KEY == 'Title'`)(preceeding)"];
    id actualResult = [json WHI_evaluateQuery:@"(all)(filter $FILTER)(preceeding)" environment:@{@"FILTER":@"$KEY == 'Title'"} error:NULL];
    XCTAssertEqualObjects(actualResult, expectedResult, @"Variable substitution failed.");
}

@end
