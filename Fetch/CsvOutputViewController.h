//
//  CsvOutputViewController.h
//  Fetch for iOS
//
//  Created by Josh on 11/2/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDSpreadView.h"

/**
 *  CsvOutputViewController is UIViewController subclass that is responsible for the displaying of the
 *  CSV output that is received when a fetch request occurs.  This data is displayed in an MDSpreadView.
 */
@interface CsvOutputViewController : UIViewController <MDSpreadViewDataSource, MDSpreadViewDelegate, UIDocumentInteractionControllerDelegate>

/**
 *  The MDSpreadView that the CSV is rendered in
 */
@property (strong, nonatomic) IBOutlet MDSpreadView *spreadView;

/**
 *  Button for instantiating the share action sheet
 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareBarButtonItem;

/**
 *  The data source for the spreadView
 */
@property (strong, nonatomic) NSMutableArray *dataSource;

/**
 *  IBAction to dismiss the CsvOutputViewController
 *
 *  @param sender The caller of this method
 */
-(IBAction)dismissSelf:(id)sender;

/**
 *  IBAction to share the csv
 *
 *  @param sender The caller of this method
 */
-(IBAction)share:(id)sender;
@end
