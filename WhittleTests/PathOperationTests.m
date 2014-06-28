//
//  WhittleTests.m
//  WhittleTests
//
//  Created by Benedict Cohen on 26/07/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WHIWhittle.h"
#import "WHIEdgeSet.h"



@interface PathOperationTests : XCTestCase
@end




@implementation PathOperationTests

-(void)testRootNodeEvaluation       //Returns the first node in the path.
{
    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(pick 0)(pick 0)(root)"];
    
    id object = @[@[@"arf"]];
    id expectResult = object;
    
    
    id nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    id actualResult = [nodeSet lastObject];
    
    XCTAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}



-(void)testPreceedingNodeEvaluation; //Returns the preceeding node in the path.
{
    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(pick `keynsham`)(pick 0)(preceeding)(pick 1)"];
    
    id stLadocRoad = @"St Ladoc Road";
    id keynshamRoads = @[@"Park Road", stLadocRoad];
    id londonRoads = @[@"Southgate Road", @"Stephendale Road"];    
    id places = @{@"keynsham":keynshamRoads, @"london":londonRoads};
    
    id expectResult = stLadocRoad;
    id object = places;
        
    id<WHIEdgeSet> nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    id actualResult = [nodeSet lastObject];
    
    XCTAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}



-(void)testEndpointNodesEvaluation  //Returns all nodes that 
{
    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(pick `keynsham`)(endpoints)"];
    
    id stLadocRoad = @"St Ladoc Road";
    id parkRoad = @"Park Road";
    id keynshamRoads = @[parkRoad, stLadocRoad];
    id londonRoads = @[@"Southgate Road", @"Stephendale Road"];    
    id places = @{@"keynsham":keynshamRoads, @"london":londonRoads};
    
    id expectResult = stLadocRoad;
    id object = places;
    
    id<WHIEdgeSet> nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    id actualResult = [nodeSet lastObject];
    
    XCTAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}



-(void)testFilterAsEndpointNodesEvaluation  //Returns all nodes that 
{
    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(pick `keynsham`)(filter `YES = YES`)"];
    
    id stLadocRoad = @"St Ladoc Road";
    id parkRoad = @"Park Road";
    id keynshamRoads = @[parkRoad, stLadocRoad];
    id londonRoads = @[@"Southgate Road", @"Stephendale Road"];    
    id places = @{@"keynsham":keynshamRoads, @"london":londonRoads};
    
    id expectResult = stLadocRoad;
    id object = places;
    
    id<WHIEdgeSet> nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    id actualResult = [nodeSet lastObject];
    
    XCTAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}



-(void)testAllNodesEvaluation       //Returns all nodes in the sub graph.
{
    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(all)"];
    
    id object = @{@"array": @[@"a", @"b", @"c"],
                  @"dict": @{   @"one": @(1),
                                @"two": @(2),
                                @"three": @(3)
                                }
                  };

    //(all) performs a breath first walk of the graph.
    //Note that keys of dictionaries are sorted alphabetically, hence 1, 3, 2.
    id expectResult = @[object, object[@"array"], object[@"dict"], @"a", @"b", @"c",  @(1), @(3), @(2)];

    
    id<WHIEdgeSet> nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    id actualResult = [nodeSet objects];
    
    XCTAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}



#pragma mark - pick tests
-(void)testKeyPickEvaluation
{
    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(pick `keyName`)"];

    id expectResult = @"Bingo!";         
    id object = @{@"keyName": expectResult};

    id actualResult = [[whittle executeWithObject:object environment:nil error:NULL] lastObject];

    XCTAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}



-(void)testIndexedPickEvaluation
{
    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(pick 1)"];
    
    id expectResult = @"Bingo!";         
    id object = @[@"arf", expectResult];
    id actualResult = [[whittle executeWithObject:object environment:nil error:NULL] lastObject];
    
    XCTAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}



#pragma mark - filter tests
-(void)testFilterEvaluation
{
    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(filter `$KEY contains 'Name'`)"];
    
    id expectResult = @"Bingo!";         
    id object = @{
                  @"keyName": expectResult,
                  @"firstName": @"arf",
                  @"surname": expectResult
                 };
    
    id <WHIEdgeSet> nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    id actualResult = [nodeSet lastObject];
    
    XCTAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}



#pragma mark - union tests
-(void)testUnionEvaluation
{
    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:@"(union (pick `0`), (pick `/``))"];

    id expectResult = @[@"a", @"c"];
    id object = @{@"0": @"a",
                  @"1": @"b",
                  @"`": @"c"};

    id <WHIEdgeSet> nodeSet = [whittle executeWithObject:object environment:nil error:NULL];
    id actualResult = [nodeSet objects];

    XCTAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}



-(void)testArf
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test.json" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    id results = [json WHI_evaluateQuery:@"(all)(filter `$KEY == 'Title'`)(preceeding)"];
    NSLog(@"%@", [results objects]);

}

@end
