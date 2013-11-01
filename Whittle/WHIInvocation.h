//
//  WHIInvocation.h
//  Whittle
//
//  Created by Benedict Cohen on 02/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 WHIInvocation is a refrence for a function and arguments to pass to the function. WHIInvocation does not provide a
 pointer to an actual function implementation (e.g. WHIFunction). It is up to the calling code to resolve
 functionName to an actual function implementation.

 */


@interface WHIInvocation : NSObject

-(id)initWithFunctionName:(NSString *)functionName arguments:(NSArray *)arguments;
@property(nonatomic, readonly) NSString *functionName;
@property(nonatomic, readonly) NSArray *arguments;

@end
