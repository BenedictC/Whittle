//
//  WHIFunctionTests.m
//  Whittle
//
//  Created by Benedict Cohen on 29/06/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WHIFunction.h"



@interface WHIFunctionTests : XCTestCase

@end



@implementation WHIFunctionTests

- (void)testInit
{
    WHIFunction *function = [[WHIFunction alloc] initWithBlock:^id<WHIEdgeSet>(id<WHIEdge> edge, NSArray *arguments, NSDictionary *environment, NSError *__autoreleasing *error) {
        return nil;
    }];
    XCTAssertNotNil(function, @"Failed to create function with valid input");

    XCTAssertThrows([[WHIFunction alloc] initWithBlock:NULL], @"Failed to throw exception when creating function with invalid argument.");
}



-(void)testEquality
{
    WHIFunction *function0 = [WHIFunction emptySetOperation];
    XCTAssertEqualObjects(function0, function0, @"Failed to compare function to its self.");


    WHIFunction *function1 = [WHIFunction functionWithBlock:^id<WHIEdgeSet>(id<WHIEdge> edge, NSArray *arguments, NSDictionary *environment, NSError *__autoreleasing *error) {
        return nil;
    }];
    WHIFunction *function2 = [WHIFunction functionWithBlock:^id<WHIEdgeSet>(id<WHIEdge> edge, NSArray *arguments, NSDictionary *environment, NSError *__autoreleasing *error) {
        return nil;
    }];
    XCTAssertNotEqualObjects(function1, function2, @"Function objects incorrectl compared as equal.");
}



-(void)testExecute
{
    __block BOOL didExecute = NO;
    WHIFunction *function = [WHIFunction functionWithBlock:^id<WHIEdgeSet>(id<WHIEdge> edge, NSArray *arguments, NSDictionary *environment, NSError *__autoreleasing *error) {
        didExecute = YES;
        return nil;
    }];

    [function executeWithEdge:nil arguments:nil environment:nil error:NULL];
    XCTAssertTrue(didExecute, @"Function failed to execute.");
}

@end
