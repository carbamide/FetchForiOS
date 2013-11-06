//
//  AppDelegate.h
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

/**
 *  The main UIWindow
 */
@property (strong, nonatomic) UIWindow *window;

/**
 *  Is the connection currently down?  If so, internetDown will be YES, else NO.
 */
@property (getter = isInternetDown) BOOL internetDown;

/**
 *  The application's documents directory
 *
 *  @return An NSURL path of the application's documents directory
 */
- (NSURL *)applicationDocumentsDirectory;

@end
