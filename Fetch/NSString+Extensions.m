//
//  NSString+Extensions.m
//  Fetch for OSX
//
//  Created by Josh on 10/4/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

+(NSString *)blankString
{
    return @"";
}

-(BOOL)hasValidURLPrefix
{
    BOOL validPrefix = NO;
    
    NSArray *validUrlPrefixes = @[@"http", @"https"];
    
    for (NSString *prefix in validUrlPrefixes) {
        if ([self hasPrefix:prefix]) {
            validPrefix = YES;
        }
    }
    
    return validPrefix;
}

-(BOOL)hasValue
{
    if (self && [self length] > 0) {
        return YES;
    }
    
    return NO;
}

@end
