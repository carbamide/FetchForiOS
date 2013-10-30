//
//  NSString+Extensions.h
//  Fetch for OSX
//
//  Created by Josh on 10/4/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

/** 
 * Blank NSString
 * 
 * @return Blank NSString
 */
+(NSString *)blankString;

/** 
 * Check if NSString has valid http or https URL prefix
 * @return Boolean of whether or not NSString has valid URL prefix
 */
-(BOOL)hasValidURLPrefix;

/**
 * Check whether NSString has value
 * @return Whether or not NSString has value
 */
-(BOOL)hasValue;

@end
