//
//  JsonOutputViewController.h
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  JsonOutputViewController is UIViewController subclass that is responsible for the displaying of the
 *  JSON output that is received when a fetch request occurs.  This data is displayed in an RATreeView.
 */
@interface JsonOutputViewController : UIViewController

/**
 *  The JSON data to display in the UITableView
 */
@property (strong, nonatomic) id jsonData;

@end
