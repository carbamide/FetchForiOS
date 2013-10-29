//
//  DataHandler.h
//  Fetch
//
//  Created by Josh on 9/8/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Projects;

@interface ProjectHandler : NSObject

+(BOOL)importFromPath:(NSString *)path error:(NSError **)error;
+(BOOL)importFromData:(NSData *)data error:(NSError **)error;
+(NSURL *)exportProject:(Projects *)project;
+(NSURL *)applicationDocumentsDirectory;

@end
