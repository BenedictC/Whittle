//
//  WHIWhittle.m
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIWhittle.h"
#import "WHIInvocation.h"
#import "WHIFunction.h"

#import "WHIEdgeSet.h"
#import "NSScanner+WhittleAdditions.h"



#pragma mark - error handling
NSString * const WHIWhittleErrorDomain = @"WHIWhittleErrorDomain";

#define RETURN_PARSE_ERROR(description, code, userInfo) return ({ \
    NSParameterAssert(outError != NULL); \
    *outError = [NSError errorWithDomain:WHIWhittleErrorDomain code:code userInfo:userInfo]; \
    nil; \
});
//userInfo[NSLocalizedFailureReasonErrorKey] = exception.reason;
//userInfo[NSLocalizedDescriptionKey] = exception.name;




#pragma mark - whittle implementation
@implementation WHIWhittle

+(NSDictionary *)defaultBindings
{
    static NSDictionary *defaultBindings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultBindings = @{
                            @"root":       [WHIFunction rootNodeOperation],
                            @"preceeding": [WHIFunction preceedingNodeOperation],
                            @"endpoints":  [WHIFunction endpointNodesOperation],
                            @"all":        [WHIFunction allNodesOperation],
                            @"pick":       [WHIFunction pickOperation],
                            @"filter":     [WHIFunction filterOperation],
                            @"union":      [WHIFunction unionOperation],
                            };
    });

    return defaultBindings;
}



#pragma mark - instance life cycle
-(id)initWithInvocationChain:(NSArray *)invocations defaultBindings:(NSDictionary *)defaultBindings
{
    NSParameterAssert(invocations);
    NSParameterAssert(defaultBindings);

    self = [super init];
    if (self == nil) return nil;

    _invocations = [invocations copy];
    _defaultBindings = [defaultBindings copy];

    return self;
}



-(id)initWithInvocationChain:(NSArray *)invocations
{
    return [self initWithInvocationChain:invocations defaultBindings:[WHIWhittle defaultBindings]];
}



-(id)init
{
    return [self initWithInvocationChain:nil defaultBindings:nil];
}



#pragma mark - evaluation
-(id<WHIEdgeSet>)executeWithObject:(id)rootObject bindings:(NSDictionary *)userBindings error:(NSError **)outError
{
    NSArray *arguments = @[rootObject, self.invocations];
    //Create the bindings
    NSMutableDictionary *mergedBindings = [[WHIWhittle defaultBindings] mutableCopy];
    if (userBindings != nil) [mergedBindings addEntriesFromDictionary:userBindings];

    //Evaluate the chain
    WHIFunction *executeInvocationChainOperation = [WHIFunction executeInvocationChainOperation];
    return [executeInvocationChainOperation executeWithEdge:nil arguments:arguments bindings:mergedBindings error:outError];
}

@end



#pragma mark - parsing/invocation factory methods
@implementation WHIWhittle (DSLFactory)

+(instancetype)whittleWithQuery:(NSString *)query
{
    NSError *outError;
    NSArray *invocations = [[self class] parseInvocationChainFromString:query error:&outError];
    if (invocations == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Whittle query. Parse error: %@", outError];
        return nil;
    }

    return [[self alloc] initWithInvocationChain:invocations];
}



+(NSArray *)parseInvocationChainFromString:(NSString *)string error:(NSError **)outError
{
    NSScanner *scanner = [NSScanner scannerWithString:string];
    scanner.charactersToBeSkipped = [NSCharacterSet controlCharacterSet];

    NSError *error;
    id result = [self parseInvocationChainFromScanner:scanner error:&error];

    if (result == nil) {
        if (outError != NULL) *outError = error;
        return nil;
    }

    return result;
}



#pragma mark - parsing methods
+(NSArray *)parseInvocationChainFromScanner:(NSScanner *)scanner error:(NSError **)outError
{
    NSMutableArray *functionInvocations = [NSMutableArray new];

    WHIInvocation *function = nil;
    do {
        function = [self parseInvocationFromScanner:scanner error:outError];
        if (function != nil) [functionInvocations addObject:function];

    } while (function != nil);

    return functionInvocations;
}



+(WHIInvocation *)parseInvocationFromScanner:(NSScanner *)scanner error:(NSError **)outError
{
    [scanner WHI_scanWhitespaceAndNewLineIntoString:NULL];

    if (![scanner scanString:@"(" intoString:NULL]) {
        //Failed to scan openning brace!
        return nil;
    }
    
    //Scan the name
    NSString *name = [self scanFunctionNameFromScanner:scanner error:outError];
    if (name == nil) {
        //Failed to scan name
        return nil;
    }

    [scanner WHI_scanWhitespaceAndNewLineIntoString:NULL];
    
    //scan optional parameters    
    NSMutableArray *arguments = [NSMutableArray new];
    id argument;
    do {
        //Reset argument.
        argument = nil;

        //Attempt to scan an argument
        if (argument == nil) argument = [self scanNumberArgumentFromScanner:scanner error:outError];
        if (argument == nil) argument = [self scanStringArgumentFromScanner:scanner error:outError];
        if (argument == nil) argument = [self scanInvocationChainArgumentFromScanner:scanner error:outError];
        
        //Commit the argument
        if (argument != nil) [arguments addObject:argument];

        [scanner WHI_scanWhitespaceAndNewLineIntoString:NULL];

    } while ([scanner scanString:@"," intoString:NULL]);

    //Scan closing brace
    if (![scanner scanString:@")" intoString:NULL]) {
        //Failed to scan closing brace!
        return nil;
    }
    
    return [[WHIInvocation alloc] initWithFunctionName:name arguments:arguments];
}



+(NSString *)scanFunctionNameFromScanner:(NSScanner *)scanner error:(NSError **)outError
{
    static NSCharacterSet *headCharacterSet = nil;
    static NSCharacterSet *bodyCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        headCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
        bodyCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"];
    });

    NSString *head = nil;
    if (![scanner scanCharactersFromSet:headCharacterSet intoString:&head]) {
        return nil;
    }
    
    NSString *body = nil;
    return ([scanner scanCharactersFromSet:bodyCharacterSet intoString:&body]) ? [head stringByAppendingString:body] : head;
}



+(NSNumber *)scanNumberArgumentFromScanner:(NSScanner *)scanner error:(NSError **)outError
{    
    double value;
    return ([scanner scanDouble:&value]) ? [NSNumber numberWithDouble:value] : nil;    
}



+(NSString *)scanStringArgumentFromScanner:(NSScanner *)scanner error:(NSError **)outError
{
    //We use backtick,`, and forward slash instead of single quote and backslash to avoid collisons.
    static NSString *const quote = @"`";
    static NSString *const escape = @"/";
    NSCharacterSet *delimiters = [NSCharacterSet characterSetWithCharactersInString:[quote stringByAppendingString:escape]];

    if (![scanner scanString:quote intoString:NULL]) {
        return nil;
    }

    NSMutableString *string = [NSMutableString string];

    //Scan the up to the closing quote.
    while (![scanner scanString:quote intoString:NULL]) {
        //is it a escape sequence?
        BOOL isEscapeSequence = [scanner scanString:escape intoString:NULL];
        if (isEscapeSequence) {
            if ([scanner scanString:quote intoString:NULL]) {
                [string appendString:quote];
            } else if ([scanner scanString:escape intoString:NULL]) {
                [string appendString:escape];
            } else {
                //TODO Invalid escape sequence. Raise exception
                return nil;
            }
        }

        //There must be more string
        NSString *buffer = nil;
        if ([scanner scanUpToCharactersFromSet:delimiters intoString:&buffer]) {
            [string appendString:buffer];
        }
    }

    return string;
}



+(NSArray *)scanInvocationChainArgumentFromScanner:(NSScanner *)scanner error:(NSError **)outError
{
    NSArray *invocations = [self parseInvocationChainFromScanner:scanner error:outError];

    return ([invocations count] == 0) ? nil : invocations;
}

@end



#pragma mark - Object addition
@implementation NSObject (Whittle)

-(id<WHIEdgeSet>)WHI_evaluateQuery:(NSString *)query bindings:(NSDictionary *)bindings error:(NSError **)outError
{
    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:query];
    //If whittle failed to initalize then this will return nil and outError will not be changed from init
    return [whittle executeWithObject:self bindings:bindings error:outError];
}



-(id<WHIEdgeSet>)WHI_evaluateQuery:(NSString *)query
{
    return [self WHI_evaluateQuery:query bindings:nil error:NULL];
}

@end

