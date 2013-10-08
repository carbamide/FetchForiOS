//
//  AddHeaderViewController.h
//  Fetch
//
//  Created by Josh on 9/26/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController, Headers;

@interface AddHeaderViewController : UIViewController

@property (strong, nonatomic) Headers *currentHeader;

@property (strong, nonatomic) UIPopoverController *selectionPopover;
@property (strong, nonatomic) DetailViewController *delegate;
@property (strong, nonatomic) IBOutlet UITextField *headerValueTextField;
@property (strong, nonatomic) IBOutlet UIButton *selectHeaderTypeButton;
@property (strong, nonatomic) IBOutlet UIButton *customHeaderButton;
@property (strong, nonatomic) IBOutlet UITextField *customHeaderTextField;

-(IBAction)cancel:(id)sender;
-(IBAction)save:(id)sender;
-(IBAction)customHeaderAction:(id)sender;
-(IBAction)selectHeaderAction:(id)sender;

@end
