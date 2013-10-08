//
//  ResponseHeadersViewController.h
//  Fetch
//
//  Created by Josh on 9/29/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResponseHeadersViewController : UITableViewController

@property (strong, nonatomic) NSArray *keysDataSource;
@property (strong, nonatomic) NSArray *valuesDataSource;

- (id)initWithStyle:(UITableViewStyle)style keysArray:(NSArray *)keys valuesArray:(NSArray *)values;

@end
