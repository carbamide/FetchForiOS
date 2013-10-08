//
//  DataModeler.h
//  Fetch
//
//  Created by Josh on 9/15/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonHandler : NSObject

-(id)init;
-(void)addEntries:(id)entries;

@property (strong, nonatomic) NSMutableArray *dataSource;

@end
