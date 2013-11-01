//
//  SelectionViewController.h
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

/**
 *  SelectionViewController is a UITableViewController subclass that handles selection of data from a list.  This list
 *  could be common HTTP headers, common HTTP methods, etc.
 */
@interface SelectionViewController : UITableViewController

/**
 *  The datasource to display in the UITableView.
 */
@property (strong, nonatomic) NSArray *dataSource;

/**
 *  The UIControl that showed this view controller
 */
@property (weak, nonatomic) id sender;

/**
 *  The view controller that shoed this view controller
 */
@property (weak, nonatomic) id delegate;

@end
