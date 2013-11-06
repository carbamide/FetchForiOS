//
//  DataHandler.h
//  Fetch
//
//  Created by Josh on 9/8/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Projects;

/**
 *  NSObject subclass that handles the importing and exporting of Projects.
 */
@interface ProjectHandler : NSObject

/**
 *  Import Project from specified path
 *
 *  @param path  Path to load the project from.
 *  @param error Error handling.
 *
 *  @return If the import was successful, the response will be YES, if not, it will be NO. and the error object will be non-nil;
 */
+(BOOL)importFromPath:(NSString *)path error:(NSError **)error;

/**
 *  Import Project from NSData object
 *
 *  @param data  NSData object that contains the Project data
 *  @param error Error handling
 *
 *  @return If the import was successful, the response will be YES, if not, it will be NO and the error object will be non-nil.
 */
+(BOOL)importFromData:(NSData *)data error:(NSError **)error;

/**
 *  Export specified project to NSURL path
 *
 *  @param project The Project object to export.
 *
 *  @return NSURL path of the Project that has been exported.  The exported file with be in .fetch format.
 */
+(NSURL *)exportProject:(Projects *)project;

/**
 *  Path to the application's documents directory
 *
 *  @return NSURL of the application's documents directory
 */
+(NSURL *)applicationDocumentsDirectory;

@end
