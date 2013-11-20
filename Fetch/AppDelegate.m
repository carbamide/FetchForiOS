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
#import "Reachability.h"

@interface AppDelegate ()
/**
 *  Reachability object that checks the devices internet connectivity
 */
@property (nonatomic) Reachability *internetReachability;

/**
 *  Reachability NSNotification handler
 *
 *  @param aNotification The NSNotification to handle
 */
- (void)reachabilityChanged:(NSNotification *)aNotification;

/**
 *  Notify the user that the reachability status has changed, or revert the user interface 
 *  to the non-interrupted status.
 *
 *  @param reachability The current Reachability status
 */
- (void)updateInterfaceWithReachability:(Reachability *)reachability;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [self setInternetReachability:[Reachability reachabilityForInternetConnection]];
    [[self internetReachability] startNotifier];
    
    [self updateInterfaceWithReachability:[self internetReachability]];
    
    UISplitViewController *splitViewController = (UISplitViewController *)[[self window] rootViewController];
    UINavigationController *navigationController = [[splitViewController viewControllers] lastObject];
    
    [splitViewController setDelegate:(id)[navigationController topViewController]];
    
    [[self window] setTintColor:UIColorFromRGB(0xb16e05)];
    
    return YES;
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
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
                
                NSError *error = nil;
                
                [ProjectHandler importFromPath:[importedProjectUrl path] error:&error];
                
                if (error) {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                         message:@"There was an error importing the Fetch document."
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil, nil];
                    
                    [errorAlert show];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_PROJECT_TABLE object:nil];
                }
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

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification *)aNotification
{
	Reachability *reachability = [aNotification object];
	NSParameterAssert([reachability isKindOfClass:[Reachability class]]);
    
	[self updateInterfaceWithReachability:reachability];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
	if (reachability == [self internetReachability]) {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        
        switch (netStatus) {
            case NotReachable: {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Internet Connection"
                                                                     message:@"An active Internet connection is required to use this application."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
                
                [errorAlert show];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:INTERNET_DOWN object:nil];
                
                [self setInternetDown:YES];
                
                break;
            }
            case ReachableViaWWAN:
            case ReachableViaWiFi: {
                [[NSNotificationCenter defaultCenter] postNotificationName:INTERNET_UP object:nil];
                
                [self setInternetDown:NO];
                
                break;
            }
        }
	}
}

@end
