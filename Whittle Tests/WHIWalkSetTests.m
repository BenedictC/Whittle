//
//  WHIWalkSetTests.m
//  Whittle
//
//  Created by Benedict Cohen on 29/06/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WHIWalkSet.h"
#import "WHIWalk.h"



@interface WHIWalkSetTests : XCTestCase

@end



@implementation WHIWalkSetTests

-(void)testInit
{
    WHIWalkSet *emptyWalkSet = [WHIWalkSet new];
    XCTAssertNotNil(emptyWalkSet, @"Failed to create empty walk set.");
    XCTAssertEqualObjects(emptyWalkSet.walks, [NSSet set], @"Failed to create empty walk set.");
    XCTAssertEqualObjects(emptyWalkSet.objects, [NSSet set], @"Failed to create empty walk set.");

    WHIWalk *walk = [[WHIWalk alloc] initWithDestinationObject:self label:nil preceedingWalk:nil];
    WHIWalkSet *walkSet =[[WHIWalkSet alloc] initWithWalk:(WHIWalk *)walk];
    XCTAssertNotNil(walkSet, @"Failed to create empty walk set.");
    XCTAssertEqualObjects(walkSet.walks, [NSSet setWithObject:walk], @"Failed to create empty walk set.");
    XCTAssertEqualObjects(walkSet.objects, [NSSet setWithObject:walk.destinationObject], @"Failed to create empty walk set.");
}



-(void)testEquality
{
    WHIWalkSet *emptyWalkSet1 = [WHIWalkSet new];
    WHIWalkSet *emptyWalkSet2 = [WHIWalkSet new];
    XCTAssertEqualObjects(emptyWalkSet1, emptyWalkSet2, @"Walk sets should be equal.");

    WHIWalk *walk = [WHIWalk walkWithDestinationObject:self];
    WHIWalkSet *walkSet1 = [WHIWalkSet walkSetWithWalk:walk];
    WHIWalkSet *walkSet2 = [WHIWalkSet walkSetWithWalk:walk];
    XCTAssertEqualObjects(walkSet1, walkSet2, @"Walk sets should be equal.");

    XCTAssertNotEqualObjects(emptyWalkSet1, walkSet1, @"Walk sets should not be equal.");
}



-(void)testAddingWalks
{
    WHIWalkSet *walkSet = [WHIWalkSet new];
    XCTAssertEqualObjects(walkSet.walks, [NSSet set], @"Walk set should be empty");

    WHIWalk *walk1 = [WHIWalk walkWithDestinationObject:self];
    [walkSet addWalk:walk1];
    XCTAssertEqualObjects(walkSet.walks, [NSSet setWithObject:walk1], @"Walk set should contain 1 walk");
}



-(void)testObjects
{
    WHIWalkSet *walkSet = [WHIWalkSet new];

    WHIWalk *walk1 = [WHIWalk walkWithDestinationObject:self];
    [walkSet addWalk:walk1];
    XCTAssertEqualObjects(walkSet.objects, [NSSet setWithObject:walk1.destinationObject], @"Walk set should contain 1 object.");

    WHIWalk *walk2 = [WHIWalk walkWithDestinationObject:[self class] label:@"class" preceedingWalk:walk1];
    [walkSet addWalk:walk2];
    id expectedResult = [NSSet setWithObjects:walk1.destinationObject, walk2.destinationObject, nil];
    XCTAssertEqualObjects(walkSet.objects, expectedResult, @"Walk set should contain 2 object.");

    //Because the walk1 and walk3 have the same destination object objects should only contain 3 objects.
    WHIWalk *walk3 = [WHIWalk walkWithDestinationObject:self label:@"instance" preceedingWalk:walk2];
    [walkSet addWalk:walk3];
    XCTAssertEqualObjects(walkSet.objects, expectedResult, @"Walk set should contain 2 object.");
}

@end
