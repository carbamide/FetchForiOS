//
//  NodeObject.h
//  Fetch
//
//  Created by Josh on 9/15/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NodeObject : NSObject

@property (strong, nonatomic) NSString *nodeTitle;
@property (strong, nonatomic) NSString *nodeValue;
@property (strong, nonatomic) NSArray *children;
@property (nonatomic) BOOL isLeaf;
@property (nonatomic) BOOL isArray;
@property (nonatomic) NSInteger objectCount;

@end
