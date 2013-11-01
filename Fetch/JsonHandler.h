//
//  DataModeler.h
//  Fetch
//
//  Created by Josh on 9/15/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  NSObject subclass that handles creating an NSArray that's suitable for consumption by JsonOutputViewController from the raw
 *  JSON data from a fetch request.
 */
@interface JsonHandler : NSObject

/**
 *  Initilization handler
 *
 *  @return JsonHandler object
 */
-(id)init;

/**
 *  Add entries to the Json
 *
 *  @param entries Entries in NSDictionary or NSArray format
 */
-(void)addEntries:(id)entries;

/**
 *  The data source to form the JSON result from
 */
@property (strong, nonatomic) NSMutableArray *dataSource;

@end
