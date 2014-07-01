//
//  WHIFunctionOperationTests.m
//  Whittle
//
//  Created by Benedict Cohen on 29/06/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WHIFunction+SetOperations.h"



@interface WHIFunctionOperationTests : XCTestCase

@end



@implementation WHIFunctionOperationTests


-(void)testRootNodeOperation
{
    WHIFunction *function1 = [WHIFunction rootNodeFunction];
    WHIFunction *function2 = [WHIFunction rootNodeFunction];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");
    XCTFail(@"TODO");
    //TODO: Test functionality of function
    //    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(pick 0)(pick 0)(root)"];
    //
    //    id object = @[@[@"arf"]];
    //    id expectedResult = object;
    //
    //
    //    id nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    //    id actualResult = [nodeSet lastObject];
    //
    //    XCTAssertEqualObjects(actualResult, expectedResult, @"Evaluation failed.");

}



-(void)testPreceedingNodeOperation
{
    WHIFunction *function1 = [WHIFunction preceedingNodesFunction];
    WHIFunction *function2 = [WHIFunction preceedingNodesFunction];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");
    XCTFail(@"TODO");
    //TODO: Test functionality of function
    //    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(pick `keynsham`)(pick 0)(preceeding)(pick 1)"];
    //
    //    id stLadocRoad = @"St Ladoc Road";
    //    id keynshamRoads = @[@"Park Road", stLadocRoad];
    //    id londonRoads = @[@"Southgate Road", @"Stephendale Road"];
    //    id places = @{@"keynsham":keynshamRoads, @"london":londonRoads};
    //
    //    id expectedResult = stLadocRoad;
    //    id object = places;
    //
    //    id<WHIEdgeSet> nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    //    id actualResult = [nodeSet lastObject];
    //
    //    XCTAssertEqualObjects(actualResult, expectedResult, @"Evaluation failed.");
}



-(void)testEndpointNodesOperation
{
    WHIFunction *function1 = [WHIFunction endpointNodesFunction];
    WHIFunction *function2 = [WHIFunction endpointNodesFunction];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");
    XCTFail(@"TODO");
    //TODO: Test functionality of function
    //    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(pick `keynsham`)(endpoints)"];
    //
    //    id stLadocRoad = @"St Ladoc Road";
    //    id parkRoad = @"Park Road";
    //    id keynshamRoads = @[parkRoad, stLadocRoad];
    //    id londonRoads = @[@"Southgate Road", @"Stephendale Road"];
    //    id places = @{@"keynsham":keynshamRoads, @"london":londonRoads};
    //
    //    id expectedResult = stLadocRoad;
    //    id object = places;
    //
    //    id<WHIEdgeSet> nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    //    id actualResult = [nodeSet lastObject];
    //
    //    XCTAssertEqualObjects(actualResult, expectedResult, @"Evaluation failed.");

}



-(void)testFilterOperation
{
    WHIFunction *function1 = [WHIFunction filterFunction];
    WHIFunction *function2 = [WHIFunction filterFunction];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");
    XCTFail(@"TODO");
    //TODO: Test functionality of function
    //    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(filter `$KEY contains 'Name'`)"];
    //
    //    id expectedResult = @"Bingo!";
    //    id object = @{
    //                  @"keyName": expectedResult,
    //                  @"firstName": @"arf",
    //                  @"surname": expectedResult
    //                  };
    //
    //    id <WHIEdgeSet> nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    //    id actualResult = [nodeSet lastObject];
    //
    //    XCTAssertEqualObjects(actualResult, expectedResult, @"Evaluation failed.");
}



-(void)testAllNodesOperation
{
    WHIFunction *function1 = [WHIFunction allNodesFunction];
    WHIFunction *function2 = [WHIFunction allNodesFunction];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");
    XCTFail(@"TODO");
    //TODO: Test functionality of function
    //    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(all)"];
    //
    //    id object = @{@"array": @[@"a", @"b", @"c"],
    //                  @"dict": @{   @"one": @(1),
    //                                @"two": @(2),
    //                                @"three": @(3)
    //                                }
    //                  };
    //
    //    //(all) performs a breath first walk of the graph.
    //    //Note that keys of dictionaries are sorted alphabetically, hence 1, 3, 2.
    //    id expectedResult = @[object, object[@"array"], object[@"dict"], @"a", @"b", @"c",  @(1), @(3), @(2)];
    //
    //
    //    id<WHIEdgeSet> nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    //    id actualResult = [nodeSet objects];
    //
    //    XCTAssertEqualObjects(actualResult, expectedResult, @"Evaluation failed.");
}



-(void)testPickOperation
{
    WHIFunction *function1 = [WHIFunction pickFunction];
    WHIFunction *function2 = [WHIFunction pickFunction];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");
    XCTFail(@"TODO");
    //TODO: Test functionality of function
    //-(void)testKeyPickEvaluation
    //{
    //    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(pick `keyName`)"];
    //
    //    id expectedResult = @"Bingo!";
    //    id object = @{@"keyName": expectedResult};
    //
    //    id actualResult = [[whittle executeWithObject:object environment:nil error:NULL] lastObject];
    //
    //    XCTAssertEqualObjects(actualResult, expectedResult, @"Evaluation failed.");
    //}
    //
    //
    //
    //-(void)testIndexedPickEvaluation
    //{
    //    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(pick 1)"];
    //
    //    id expectedResult = @"Bingo!";
    //    id object = @[@"arf", expectedResult];
    //    id actualResult = [[whittle executeWithObject:object environment:nil error:NULL] lastObject];
    //
    //    XCTAssertEqualObjects(actualResult, expectedResult, @"Evaluation failed.");

}



-(void)testUnionOperation
{
    WHIFunction *function1 = [WHIFunction unionOperation];
    WHIFunction *function2 = [WHIFunction unionOperation];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");
    XCTFail(@"TODO");
    //TODO: Test functionality of function
    //    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(union (pick `0`), (pick `/``))"];
    //
    //    id expectedResult = @[@"a", @"c"];
    //    id object = @{@"0": @"a",
    //                  @"1": @"b",
    //                  @"`": @"c"};
    //
    //    id <WHIEdgeSet> nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    //    id actualResult = [nodeSet objects];
    //
    //    XCTAssertEqualObjects(actualResult, expectedResult, @"Evaluation failed.");

}

@end


