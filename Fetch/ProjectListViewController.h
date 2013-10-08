//
//  MasterViewController.h
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSCMoreOptionTableViewCellDelegate.h"
#import "MSCMoreOptionTableViewCell.h"

@class DetailViewController;

#import <CoreData/CoreData.h>

@interface ProjectListViewController : UITableViewController <UIAlertViewDelegate, MSCMoreOptionTableViewCellDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) UIPopoverController *activityPopoverController;

@end
