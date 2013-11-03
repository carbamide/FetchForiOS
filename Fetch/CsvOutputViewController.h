//
//  CsvOutputViewController.h
//  Fetch for iOS
//
//  Created by Josh on 11/2/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDSpreadView.h"

@interface CsvOutputViewController : UIViewController <MDSpreadViewDataSource, MDSpreadViewDelegate>

@property (strong, nonatomic) IBOutlet MDSpreadView *spreadView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImage *backgroundImage;

@property (strong, nonatomic) NSMutableArray *dataSource;

-(IBAction)dismissSelf:(id)sender;

@end
