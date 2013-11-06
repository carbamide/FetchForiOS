//
//  ResponseHeadersViewController.h
//  Fetch
//
//  Created by Josh on 9/29/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  UITableViewController subclass that handles the displaying of the headers that are received
 *  in the response data when a fetch request occurs.
 */
@interface ResponseHeadersViewController : UITableViewController

/**
 *  Keys to be shown in the table view
 */
@property (strong, nonatomic) NSArray *keysDataSource;

/**
 *  Values cooresponding to the keys shown in the table view
 */
@property (strong, nonatomic) NSArray *valuesDataSource;

/**
 *  Custom init method that passes keys and values to this view controller
 *
 *  @param style  The UITableViewStyle to use for this table
 *  @param keys   An array of keys to show in the table
 *  @param values An array of cooresponding values to show in the table
 *
 *  @return ResponseHeadersViewController object
 */
- (id)initWithStyle:(UITableViewStyle)style keysArray:(NSArray *)keys valuesArray:(NSArray *)values;

@end
