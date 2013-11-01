//
//  NSScanner+WhittleAdditions.m
//  Whittle
//
//  Created by Benedict Cohen on 02/09/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "NSScanner+WhittleAdditions.h"



@implementation NSScanner (WhittleAdditions)

-(NSString *)WHI_remainingString
{
    return [self.string substringFromIndex:self.scanLocation];
}



-(BOOL)WHI_scanWhitespaceAndNewLineIntoString:(NSString *__autoreleasing *)outString
{
    return [self scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:outString];
}

@end
