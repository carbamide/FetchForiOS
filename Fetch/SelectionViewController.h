//
//  SelectionViewController.h
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface SelectionViewController : UITableViewController

@property (strong, nonatomic) NSArray *dataSource;
@property (weak, nonatomic) id sender;
@property (weak, nonatomic) id delegate;

@end
