//
//  WhittleTests.m
//  WhittleTests
//
//  Created by Benedict Cohen on 26/07/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "WHIWhittle.h"
#import "WHIPathSet.h"



@interface PathOperationTests : SenTestCase
@end



@implementation PathOperationTests

-(void)testRootNodeEvaluation       //Returns the first node in the path.
{
    WHIWhittle *whittle = [[WHIWhittle alloc] initWithPath:@"(pick 0)(pick 0)(root)" error:NULL];
    
    id object = @[@[@"arf"]];
    id expectResult = object;
    
    
    id nodeSet = [whittle evaluateWithObject:object bindings:nil error:NULL];
    id actualResult = [nodeSet lastObject];
    
    STAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");    
}



-(void)testPreceedingNodeEvaluation; //Returns the preceeding node in the path.
{
    WHIWhittle *whittle = [[WHIWhittle alloc] initWithPath:@"(pick `keynsham`)(pick 0)(preceeding)(pick 1)" error:NULL];
    
    id stLadocRoad = @"St Ladoc Road";
    id keynshamRoads = @[@"Park Road", stLadocRoad];
    id londonRoads = @[@"Southgate Road", @"Stephendale Road"];    
    id places = @{@"keynsham":keynshamRoads, @"london":londonRoads};
    
    id expectResult = stLadocRoad;
    id object = places;
        
    id<WHIPathSet> nodeSet = [whittle evaluateWithObject:object bindings:nil error:NULL];
    id actualResult = [nodeSet lastObject];
    
    STAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");    
}



-(void)testEndpointNodesEvaluation  //Returns all nodes that 
{
    WHIWhittle *whittle = [[WHIWhittle alloc] initWithPath:@"(pick `keynsham`)(endpoints)" error:NULL];
    
    id stLadocRoad = @"St Ladoc Road";
    id parkRoad = @"Park Road";
    id keynshamRoads = @[parkRoad, stLadocRoad];
    id londonRoads = @[@"Southgate Road", @"Stephendale Road"];    
    id places = @{@"keynsham":keynshamRoads, @"london":londonRoads};
    
    id expectResult = stLadocRoad;
    id object = places;
    
    id<WHIPathSet> nodeSet = [whittle evaluateWithObject:object bindings:nil error:NULL];
    id actualResult = [nodeSet lastObject];
    
    STAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");     
}



-(void)testFilterAsEndpointNodesEvaluation  //Returns all nodes that 
{
    WHIWhittle *whittle = [[WHIWhittle alloc] initWithPath:@"(pick `keynsham`)(filter `YES = YES`)" error:NULL];
    
    id stLadocRoad = @"St Ladoc Road";
    id parkRoad = @"Park Road";
    id keynshamRoads = @[parkRoad, stLadocRoad];
    id londonRoads = @[@"Southgate Road", @"Stephendale Road"];    
    id places = @{@"keynsham":keynshamRoads, @"london":londonRoads};
    
    id expectResult = stLadocRoad;
    id object = places;
    
    id<WHIPathSet> nodeSet = [whittle evaluateWithObject:object bindings:nil error:NULL];
    id actualResult = [nodeSet lastObject];
    
    STAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");     
}



-(void)testAllNodesEvaluation       //Returns all nodes in the sub graph.
{
    WHIWhittle *whittle = [[WHIWhittle alloc] initWithPath:@"(all)" error:NULL];
    
    id object = @{@"array": @[@"a", @"b", @"c"],
                  @"dict": @{   @"one": @(1),
                                @"two": @(2),
                                @"three": @(3)
                                }
                  };

    //(all) performs a breath first walk of the graph.
    //Note that keys of dictionaries are sorted alphabetically, hence 1, 3, 2.
    id expectResult = @[object, object[@"array"], object[@"dict"], @"a", @"b", @"c",  @(1), @(3), @(2)];

    
    id<WHIPathSet> nodeSet = [whittle evaluateWithObject:object bindings:nil error:NULL];
    id actualResult = [nodeSet objects];
    
    STAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");     
}



#pragma mark - pick tests
-(void)testKeyPickEvaluation
{
    WHIWhittle *whittle = [[WHIWhittle alloc] initWithPath:@"(pick `keyName`)" error:NULL];

    id expectResult = @"Bingo!";         
    id object = @{@"keyName": expectResult};

    id actualResult = [[whittle evaluateWithObject:object bindings:nil error:NULL] lastObject];

    STAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}



-(void)testIndexedPickEvaluation
{
    WHIWhittle *whittle = [[WHIWhittle alloc] initWithPath:@"(pick 1)" error:NULL];
    
    id expectResult = @"Bingo!";         
    id object = @[@"arf", expectResult];
    id actualResult = [[whittle evaluateWithObject:object bindings:nil error:NULL] lastObject];
    
    STAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}



#pragma mark - filter tests
-(void)testFilterEvaluation
{
    WHIWhittle *whittle = [[WHIWhittle alloc] initWithPath:@"(filter `$KEY contains 'Name'`)" error:NULL];
    
    id expectResult = @"Bingo!";         
    id object = @{
                  @"keyName": expectResult,
                  @"firstName": @"arf",
                  @"surname": expectResult
                 };
    
    id <WHIPathSet> nodeSet = [whittle evaluateWithObject:object bindings:nil error:NULL];
    id actualResult = [nodeSet lastObject];
    
    STAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}



#pragma mark - union tests
-(void)testUnionEvaluation
{
    WHIWhittle *whittle = [[WHIWhittle alloc] initWithPath:@"(union (pick `0`), (pick `/``))" error:NULL];

    id expectResult = @[@"a", @"c"];
    id object = @{@"0": @"a",
                  @"1": @"b",
                  @"`": @"c"};

    id <WHIPathSet> nodeSet = [whittle evaluateWithObject:object bindings:nil error:NULL];
    id actualResult = [nodeSet objects];

    STAssertEqualObjects(actualResult, expectResult, @"Evaluation failed.");
}

@end
