//
//  UrlListViewController.h
//  Fetch
//
//  Created by Josh on 9/26/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Projects;

/**
 *  UITableViewController subclass that is responsible for displaying the Urls that are contained in the currentlys
 *  selected Project object.
 */
@interface UrlListViewController : UITableViewController

/**
 *  The current select Project
 */
@property (strong, nonatomic) Projects *currentProject;

/**
 *  Add a new Url object to the currentProject
 *
 *  @param sender The caller of this method
 */
-(IBAction)addUrl:(id)sender;

@end
