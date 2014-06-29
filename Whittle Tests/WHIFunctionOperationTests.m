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
    WHIFunction *function1 = [WHIFunction rootNodeOperation];
    WHIFunction *function2 = [WHIFunction rootNodeOperation];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");

    //TODO: Test functionality of function
}



-(void)testPreceedingNodeOperation
{
    WHIFunction *function1 = [WHIFunction preceedingNodeOperation];
    WHIFunction *function2 = [WHIFunction preceedingNodeOperation];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");

    //TODO: Test functionality of function
}



-(void)testEndpointNodesOperation
{
    WHIFunction *function1 = [WHIFunction endpointNodesOperation];
    WHIFunction *function2 = [WHIFunction endpointNodesOperation];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");

    //TODO: Test functionality of function
}



-(void)testFilterOperation
{
    WHIFunction *function1 = [WHIFunction filterOperation];
    WHIFunction *function2 = [WHIFunction filterOperation];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");

    //TODO: Test functionality of function
}



-(void)testAllNodesOperation
{
    WHIFunction *function1 = [WHIFunction allNodesOperation];
    WHIFunction *function2 = [WHIFunction allNodesOperation];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");

    //TODO: Test functionality of function
}



-(void)testPickOperation
{
    WHIFunction *function1 = [WHIFunction pickOperation];
    WHIFunction *function2 = [WHIFunction pickOperation];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");

    //TODO: Test functionality of function
}



-(void)testUnionOperation
{
    WHIFunction *function1 = [WHIFunction unionOperation];
    WHIFunction *function2 = [WHIFunction unionOperation];
    XCTAssertEqualObjects(function1, function2, @"Class method failed to return same object.");

    //TODO: Test functionality of function
}



//-(void)testRootNodeEvaluation       //Returns the first node in the path.
//{
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
//}
//
//
//
//-(void)testPreceedingNodeEvaluation; //Returns the preceeding node in the path.
//{
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
//}
//
//
//
//-(void)testEndpointNodesEvaluation  //Returns all nodes that
//{
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
//}
//
//
//
//-(void)testFilterAsEndpointNodesEvaluation  //Returns all nodes that
//{
//    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(pick `keynsham`)(filter `YES = YES`)"];
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
//}
//
//
//
//-(void)testAllNodesEvaluation       //Returns all nodes in the sub graph.
//{
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
//}
//
//
//
//#pragma mark - pick tests
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
//}
//
//
//
//#pragma mark - filter tests
//-(void)testFilterEvaluation
//{
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
//}
//
//
//
//#pragma mark - union tests
//-(void)testUnionEvaluation
//{
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
//}

@end


