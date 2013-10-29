//
//  DetailViewController.h
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"

@class Projects;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) Projects *currentProject;

@property (strong, nonatomic) UIPopoverController *selectionPopover;
@property (strong, nonatomic) UIPopoverController *responseHeadersPopover;
@property (strong, nonatomic) UIPopoverController *jsonPopover;

@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *urlTextField;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *urlDescriptionTextField;
@property (strong, nonatomic) IBOutlet UIButton *methodsButton;
@property (strong, nonatomic) IBOutlet UIButton *fetchButton;
@property (strong, nonatomic) IBOutlet UISwitch *customPayloadSwitch;
@property (strong, nonatomic) IBOutlet UITableView *headersTableView;
@property (strong, nonatomic) IBOutlet UITableView *parametersTableView;
@property (strong, nonatomic) IBOutlet UITextView *outputTextView;
@property (strong, nonatomic) IBOutlet UITextView *customPayloadTextView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *headersSegCont;
@property (strong, nonatomic) IBOutlet UISegmentedControl *parametersSegCont;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *fetchActivityIndicator;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *clearButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *jsonOutputButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *responseHeadersButton;

-(IBAction)methodsAction:(id)sender;
-(IBAction)fetchAction:(id)sender;
-(IBAction)segmentedControlAction:(id)sender;
-(IBAction)showJsonOutputAction:(id)sender;
-(IBAction)clearAction:(id)sender;
-(IBAction)showCustomPayloadAction:(id)sender;
-(IBAction)showResponseHeadersAction:(id)sender;

@end
