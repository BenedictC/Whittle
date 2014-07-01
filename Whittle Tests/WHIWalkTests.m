//
//  WHIWalkTests.m
//  Whittle
//
//  Created by Benedict Cohen on 29/06/2014.
//  Copyright (c) 2014 Benedict Cohen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WHIWalk.h"



@interface WHIWalkTests : XCTestCase

@end



@implementation WHIWalkTests

-(void)testInit
{
    XCTAssertThrows([WHIWalk new], @"Failed to throw exception with invalid destination object.");

    id object = @{};
    WHIWalk *preceedingWalk = [[WHIWalk alloc] initWithDestinationObject:object label:nil preceedingWalk:nil];
    WHIWalk *walk = [[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:preceedingWalk];
    XCTAssertEqualObjects(walk.destinationObject, object, @"objects are not equal.");
    XCTAssertEqualObjects(walk.preceedingWalk, preceedingWalk, @"preecedingEdge are not equal.");

    XCTAssertThrows([[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:nil], @"Failed to throw exception with invalid init arguments.");
    XCTAssertThrows([[WHIWalk alloc] initWithDestinationObject:object label:nil preceedingWalk:walk], @"Failed to throw exception with invalid init arguments.");
}



-(void)testEquality
{
    id object = @"";
    WHIWalk *edge1 = [[WHIWalk alloc] initWithDestinationObject:object label:nil preceedingWalk:nil];
    WHIWalk *edge2 = [[WHIWalk alloc] initWithDestinationObject:object label:nil preceedingWalk:nil];
    XCTAssertEqualObjects(edge1, edge2, @"Edges expected to be equal.");

    WHIWalk *edge3 = [[WHIWalk alloc] initWithDestinationObject:object label:nil preceedingWalk:nil];
    WHIWalk *edge4 = [[WHIWalk alloc] initWithDestinationObject:self label:nil preceedingWalk:nil];
    XCTAssertNotEqualObjects(edge3, edge4, @"Edges expected to be unequal.");

    WHIWalk *edge5 = [[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:edge3];
    WHIWalk *edge6 = [[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:edge3];
    XCTAssertEqualObjects(edge5, edge6, @"Edges expected to be equal.");

    WHIWalk *edge7 = [[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:edge3];
    WHIWalk *edge8 = [[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:edge4];
    XCTAssertNotEqualObjects(edge7, edge8, @"Edges expected to be unequal.");
}

@end
