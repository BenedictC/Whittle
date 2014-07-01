//
//  WHIFunctionTests.m
//  Whittle
//
//  Created by Benedict Cohen on 29/06/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WHIFunction.h"
#import "WHIWalkSet.h"



@interface WHIFunctionTests : XCTestCase

@end



@implementation WHIFunctionTests

- (void)testInit
{
    WHIFunction *function = [[WHIFunction alloc] initWithBlock:^id<WHIWalkSet>(id<WHIWalkSet> walkSet, NSArray *arguments, NSDictionary *environment, NSError *__autoreleasing *error) {
        return nil;
    }];
    XCTAssertNotNil(function, @"Failed to create function with valid input");

    XCTAssertThrows([[WHIFunction alloc] initWithBlock:NULL], @"Failed to throw exception when creating function with invalid argument.");
}



-(void)testEquality
{
    WHIFunction *function0 = [WHIFunction emptySetFunction];
    XCTAssertEqualObjects(function0, function0, @"Failed to compare function to its self.");


    WHIFunction *function1 = [WHIFunction functionWithBlock:^id<WHIWalkSet>(id<WHIWalkSet> walkSet, NSArray *arguments, NSDictionary *environment, NSError *__autoreleasing *error) {
        return nil;
    }];
    WHIFunction *function2 = [WHIFunction functionWithBlock:^id<WHIWalkSet>(id<WHIWalkSet> walkSet, NSArray *arguments, NSDictionary *environment, NSError *__autoreleasing *error) {
        return nil;
    }];
    XCTAssertNotEqualObjects(function1, function2, @"Function objects incorrectl compared as equal.");
}



-(void)testExecute
{
    WHIWalkSet *input = [WHIWalkSet walkSetWithWalkToDestinationObject:self label:nil preceedingWalk:nil];
    WHIWalkSet *output = [WHIWalkSet walkSetWithWalkToDestinationObject:[self class] label:@"arf" preceedingWalk:[input.walks anyObject]];
    NSArray *arguments = @[@"arf"];
    NSDictionary *enviornment = @{@"BOOL" : @YES};
    NSError *error = [NSError new];

    WHIFunction *function = [WHIFunction functionWithBlock:^id<WHIWalkSet>(id<WHIWalkSet> fWalkSet, NSArray *fArguments, NSDictionary *fEnvironment, NSError *__autoreleasing *fError) {
        XCTAssertEqualObjects(fWalkSet, input, @"Failed to pass parameter to block");
        XCTAssertEqualObjects(fArguments, arguments, @"Failed to pass parameter to block");
        XCTAssertEqualObjects(fEnvironment, enviornment, @"Failed to pass parameter to block");
        XCTAssertEqualObjects(error, *fError, @"Failed to pass parameter to block");
        return output;
    }];

    id result = [function executeWithWalk:input arguments:arguments environment:enviornment error:&error];
    XCTAssertEqualObjects(result, output, @"Failed to return expect object from execution.");
}

@end
