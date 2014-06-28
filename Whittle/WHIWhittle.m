//
//  WHIWhittle.m
//  Whittle
//
//  Created by Benedict Cohen on 18/08/2013.
//  Copyright (c) 2013 Benedict Cohen. All rights reserved.
//

#import "WHIWhittle.h"
#import "WHIInvocation.h"
#import "WHIFunction+SetOperations.h"

#import "WHIEdgeSet.h"
#import "NSScanner+WhittleAdditions.h"



#pragma mark - error handling
NSString * const WHIWhittleErrorDomain = @"WHIWhittleErrorDomain";



#pragma mark - whittle implementation
@implementation WHIWhittle

+(NSDictionary *)defaultEnvironment
{
    static NSDictionary *defaultEnvironment = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultEnvironment = @{
                            @"root":       [WHIFunction rootNodeOperation],
                            @"preceeding": [WHIFunction preceedingNodeOperation],
                            @"endpoints":  [WHIFunction endpointNodesOperation],
                            @"all":        [WHIFunction allNodesOperation],
                            @"pick":       [WHIFunction pickOperation],
                            @"filter":     [WHIFunction filterOperation],
                            @"union":      [WHIFunction unionOperation],
                            };
    });

    return defaultEnvironment;
}



#pragma mark - instance life cycle
-(id)initWithInvocationList:(NSArray *)invocations defaultEnvironment:(NSDictionary *)defaultEnvironment
{
    NSParameterAssert(invocations);
    NSParameterAssert(defaultEnvironment);

    self = [super init];
    if (self == nil) return nil;

    _invocations = [invocations copy];
    _defaultEnvironment = [defaultEnvironment copy];

    return self;
}



-(id)initWithInvocationList:(NSArray *)invocations
{
    return [self initWithInvocationList:invocations defaultEnvironment:[WHIWhittle defaultEnvironment]];
}



-(id)init
{
    return [self initWithInvocationList:nil defaultEnvironment:nil];
}



#pragma mark - evaluation
-(id<WHIEdgeSet>)executeWithObject:(id)rootObject environment:(NSDictionary *)userEnvironment error:(NSError **)outError
{
    //Create the environment
    NSMutableDictionary *mergedEnvironment = [[WHIWhittle defaultEnvironment] mutableCopy];
    if (userEnvironment != nil) [mergedEnvironment addEntriesFromDictionary:userEnvironment];

    //Execute the list
    WHIEdgeSet *inputSet = [WHIEdgeSet edgeSetWithEdgeToDestinationObject:rootObject preceedingEdge:nil userInfo:nil];
    return [WHIInvocation executeInvocationList:self.invocations edgeSet:inputSet environment:mergedEnvironment error:outError];
}

@end



#pragma mark - parsing/invocation factory methods
@implementation WHIWhittle (DSLFactory)

+(instancetype)whittleWithQuery:(NSString *)query
{
    NSError *outError;
    NSArray *invocations = [[self class] parseInvocationListFromString:query error:&outError];
    if (invocations == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Whittle query. Parse error: %@", outError];
        return nil;
    }

    return [[self alloc] initWithInvocationList:invocations];
}



+(NSArray *)parseInvocationListFromString:(NSString *)string error:(NSError **)outError
{
    NSScanner *scanner = [NSScanner scannerWithString:string];
    scanner.charactersToBeSkipped = [NSCharacterSet controlCharacterSet];

    NSError *error;
    id result = [self parseInvocationListFromScanner:scanner error:&error];

    if (result == nil) {
        if (outError != NULL) *outError = error;
        return nil;
    }

    return result;
}



#pragma mark - parsing methods
+(NSArray *)parseInvocationListFromScanner:(NSScanner *)scanner error:(NSError **)outError
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
        if (argument == nil) argument = [self scanInvocationListArgumentFromScanner:scanner error:outError];
        
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



+(NSArray *)scanInvocationListArgumentFromScanner:(NSScanner *)scanner error:(NSError **)outError
{
    NSArray *invocations = [self parseInvocationListFromScanner:scanner error:outError];

    return ([invocations count] == 0) ? nil : invocations;
}

@end



#pragma mark - Object addition
@implementation NSObject (Whittle)

-(id<WHIEdgeSet>)WHI_evaluateQuery:(NSString *)query environment:(NSDictionary *)environment error:(NSError **)outError
{
    WHIWhittle *whittle = [WHIWhittle whittleWithQuery:query];
    //If whittle failed to initalize then this will return nil and outError will not be changed from init
    return [whittle executeWithObject:self environment:environment error:outError];
}



-(id<WHIEdgeSet>)WHI_evaluateQuery:(NSString *)query
{
    return [self WHI_evaluateQuery:query environment:nil error:NULL];
}

@end

