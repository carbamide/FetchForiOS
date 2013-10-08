//
//  AppDelegate.m
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "AppDelegate.h"
#import "ProjectListViewController.h"
#import "ProjectHandler.h"
#import "Constants.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UISplitViewController *splitViewController = (UISplitViewController *)[[self window] rootViewController];
    UINavigationController *navigationController = [[splitViewController viewControllers] lastObject];
    
    [splitViewController setDelegate:(id)[navigationController topViewController]];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (url != nil && [url isFileURL]) {
		if ([[url lastPathComponent] rangeOfString:@"fetch" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[[[self applicationDocumentsDirectory] URLByAppendingPathComponent:[url lastPathComponent]] path] isDirectory:nil]) {
                [[NSFileManager defaultManager] removeItemAtURL:[[self applicationDocumentsDirectory] URLByAppendingPathComponent:[url lastPathComponent]] error:nil];
            }
            
			NSError *error = nil;
			
			[[NSFileManager defaultManager] moveItemAtURL:url toURL:[[self applicationDocumentsDirectory] URLByAppendingPathComponent:[url lastPathComponent]] error:&error];
            
            if (error) {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:[error localizedDescription]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
                
                [errorAlert show];
            }
            else {
                NSURL *importedProjectUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[url lastPathComponent]];
                
                [ProjectHandler importFromPath:[importedProjectUrl path]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_PROJECT_TABLE object:nil];
            }
		}
	}
	
	return YES;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
