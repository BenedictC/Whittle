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
    WHIWalk *walk = [[WHIWalk alloc] initWithDestinationObject:object label:nil preceedingWalk:preceedingWalk];
    XCTAssertEqualObjects(walk.destinationObject, object, @"objects are not equal.");
    XCTAssertEqualObjects(walk.preceedingWalk, preceedingWalk, @"preecedingEdge are not equal.");
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



    WHIWalk *edge5 = [[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:nil];
    WHIWalk *edge6 = [[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:nil];
    XCTAssertEqualObjects(edge5, edge6, @"Edges expected to be equal.");

    WHIWalk *edge7 = [[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:nil];
    WHIWalk *edge8 = [[WHIWalk alloc] initWithDestinationObject:object label:@"not arf" preceedingWalk:nil];
    XCTAssertNotEqualObjects(edge7, edge8, @"Edges expected to be unequal.");



    WHIWalk *edge9 = [[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:edge3];
    WHIWalk *edge10 = [[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:edge3];
    XCTAssertEqualObjects(edge9, edge10, @"Edges expected to be equal.");

    WHIWalk *edge11 = [[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:edge3];
    WHIWalk *edge12 = [[WHIWalk alloc] initWithDestinationObject:object label:@"arf" preceedingWalk:edge4];
    XCTAssertNotEqualObjects(edge11, edge12, @"Edges expected to be unequal.");

}

@end
