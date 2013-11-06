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

/**
 *  UITableViewController subclass that conforms to UIAlertViewDelegate, NSCMoreOptionTableViewCellDelegate, and UIActionSheetDelegate.
 *  ProjectListViewController is responsible for displaying and editing the Projects that are contained in the application.
 */
@interface ProjectListViewController : UITableViewController <UIAlertViewDelegate, MSCMoreOptionTableViewCellDelegate, UIActionSheetDelegate>

/**
 *  Reference to DetailViewController
 */
@property (strong, nonatomic) DetailViewController *detailViewController;

/**
 *  UIPopoverController that holds the export activities
 */
@property (strong, nonatomic) UIPopoverController *activityPopoverController;

@end
