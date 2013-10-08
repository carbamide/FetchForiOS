//
//  UrlListViewController.h
//  Fetch
//
//  Created by Josh on 9/26/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Projects;

@interface UrlListViewController : UITableViewController

@property (strong, nonatomic) Projects *currentProject;

-(IBAction)addUrl:(id)sender;

@end
