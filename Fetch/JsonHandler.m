//
//  DataModeler.m
//  Fetch
//
//  Created by Josh on 9/15/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "JsonHandler.h"
#import "NodeObject.h"
#import "SeparatorNodeObject.h"

@implementation JsonHandler

- (id)init
{
	self = [super init];
    
    if (self) {
        [self setDataSource:[NSMutableArray array]];
	}
    
	return self;
}

-(void)addEntries:(id)entries
{
    if (!entries) {
        return;
    }
    
    NSAssert([entries isKindOfClass:[NSDictionary class]], @"Entries must be a dictionary");
    
    if ([entries isKindOfClass:[NSDictionary class]]) {
        [self addDictionary:entries array:nil separator:NO];
    }
}

-(void)addDictionary:(NSDictionary *)dict array:(NSMutableArray **)array separator:(BOOL)needsSeparator
{
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NodeObject *tempArrayObject = [[NodeObject alloc] init];
            
            [tempArrayObject setNodeTitle:key];
            [tempArrayObject setIsArray:YES];
            [tempArrayObject setIsLeaf:NO];
            
            [self addArray:dict[key] node:tempArrayObject];
            
            if (array != NULL) {
                [*array addObject:tempArrayObject];
            }
            else {
                [[self dataSource] addObject:tempArrayObject];
            }
        }
        else {
            NodeObject *tempDictObject = [[NodeObject alloc] init];
            
            [tempDictObject setNodeTitle:key];
            
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [self addChildren:obj parent:tempDictObject];
            }
            else {
                [tempDictObject setNodeValue:obj];
            }
            
            [tempDictObject setIsArray:NO];
            [tempDictObject setIsLeaf:YES];
            
            if (array != NULL) {
                [*array addObject:tempDictObject];
            }
            else {
                [[self dataSource] addObject:tempDictObject];
            }
        }
    }];
    
    if (needsSeparator) {
        SeparatorNodeObject *tempSep = [[SeparatorNodeObject alloc] init];
        
        [*array addObject:tempSep];
    }
}

-(void)addArray:(NSArray *)array node:(NodeObject *)nodeObject
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    NSInteger objectCount = 0;
    
    for (id tempValue in array) {
        objectCount++;
        if ([tempValue isKindOfClass:[NSDictionary class]]) {
            if (tempValue == [array lastObject]) {
                
                [self addDictionary:tempValue array:&tempArray separator:NO];
            }
            else {
                [self addDictionary:tempValue array:&tempArray separator:YES];
            }
        }
        else if ([tempValue isKindOfClass:[NSArray class]]) {
            [self addArray:tempValue node:nodeObject];
        }
    }
    
    [nodeObject setObjectCount:objectCount];
    [nodeObject setChildren:tempArray];
}

-(void)addChildren:(NSDictionary *)dict parent:(NodeObject *)parent
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NodeObject *tempArrayObject = [[NodeObject alloc] init];
            
            [tempArrayObject setNodeTitle:@"Array"];
            [tempArrayObject setIsArray:YES];
            [tempArrayObject setIsLeaf:NO];
            
            [self addArray:dict[key] node:tempArrayObject];
            
            [tempArray addObject:tempArrayObject];
        }
        else {
            NodeObject *tempDictObject = [[NodeObject alloc] init];
            
            [tempDictObject setNodeTitle:key];
            [tempDictObject setNodeValue:obj];
            [tempDictObject setIsArray:NO];
            [tempDictObject setIsLeaf:YES];
            
            [tempArray addObject:tempDictObject];
        }
    }];
    
    [parent setChildren:tempArray];
}

@end
