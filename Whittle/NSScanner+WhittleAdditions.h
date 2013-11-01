//
//  NSScanner+WhittleAdditions.h
//  Whittle
//
//  Created by Benedict Cohen on 02/09/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSScanner (WhittleAdditions)
-(NSString *)WHI_remainingString;
-(BOOL)WHI_scanWhitespaceAndNewLineIntoString:(NSString *__autoreleasing *)outString;
@end
