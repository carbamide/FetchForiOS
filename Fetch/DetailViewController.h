//
//  DetailViewController.h
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"
#import "MRActivityIndicatorView.h"

@class Projects;

/**
 *  The bread and butter of the application.  DetailViewController is a UIViewController subclass that conforms to
 *  UISplitViewControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UISearchBarDelegate, and UITextViewDelegate.  DetailViewController is responsible
 *  for the direct manipulation of the currently selected Url object as well as the creation of new Url objects.
 *
 *  DetailViewController is also responsible for the actual fetch action, as well as handling the data that occurs
 *  from that fetch action.
 */
@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UISearchBarDelegate>

/**
 *  The current Project
 */
@property (strong, nonatomic) Projects *currentProject;

/**
 *  UIPopoverController that holds the SelectionViewController
 */
@property (strong, nonatomic) UIPopoverController *selectionPopover;

/**
 *  UIPopoverController that holds the ResponseHeadersViewController
 */
@property (strong, nonatomic) UIPopoverController *responseHeadersPopover;

/**
 *  UIPopoverController that holds the JsonOutputViewController
 */
@property (strong, nonatomic) UIPopoverController *jsonPopover;

/**
 *  Text field that holds the URL of the current URL object
 */
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *urlTextField;

/**
 *  Description of the URL contained in urlTextField
 */
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *urlDescriptionTextField;

/**
 *  UIButton that shows the SelectionViewController when selected
 */
@property (strong, nonatomic) IBOutlet UIButton *methodsButton;

/**
 *  UIButton that performs the fetchAction:
 */
@property (strong, nonatomic) IBOutlet UIButton *fetchButton;

/**
 *  UISwitch that shows the customPayloadTextView that allows custom POST payloads to be attached to the fetch
 */
@property (strong, nonatomic) IBOutlet UISwitch *customPayloadSwitch;

/**
 *  UITableView that lets the user specify headers for the fetch
 */
@property (strong, nonatomic) IBOutlet UITableView *headersTableView;

/**
 *  UITableView that lets the user specify parameters for the fetch
 */
@property (strong, nonatomic) IBOutlet UITableView *parametersTableView;

/**
 *  UITextView that shows the output from the fetch, as well as the HTTP response code, HEADERS, etc
 */
@property (strong, nonatomic) IBOutlet UITextView *outputTextView;

/**
 *  UITextView that allows the user to specify a custom payload for POST fetch actions
 */
@property (strong, nonatomic) IBOutlet UITextView *customPayloadTextView;

/**
 *  UISegmentedControl that allows the user to add or remove headers
 */
@property (strong, nonatomic) IBOutlet UISegmentedControl *headersSegCont;

/**
 *  UISegmentedControl that allows the user to add or remove parameters
 */
@property (strong, nonatomic) IBOutlet UISegmentedControl *parametersSegCont;

/**
 *  MRActivityIndicatorView that shows when a fetch has begun, in place of the fetchButton
 */
@property (strong, nonatomic) IBOutlet MRActivityIndicatorView *fetchActivityIndicator;

/**
 *  UIButton that allows the user to clear the contents of outputTextView
 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *clearButton;

/**
 *  UIBarButtonItem that allows the user to show the JsonOutputViewController
 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *parseButton;

/**
 *  UIBarButtonItem that allows the user to show the ResponseHeadersViewController
 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *responseHeadersButton;

/**
 *  UISearchbar to search the outputTextView
 */
@property (strong, nonatomic) UISearchBar *searchBar;

/**
 *  Action for methodsButton that shows the selection of HTTP methods
 *
 *  @param sender The caller of this method
 */
-(IBAction)methodsAction:(id)sender;

/**
 *  The meat and potatoes of this app.  This IBAction performs the fetch request.
 *
 *  @param sender The caller of this method.
 */
-(IBAction)fetchAction:(id)sender;

/**
 *  Adds or removes headers or parameters from the headersTableView or the parametersTableView.
 *
 *  @param sender The caller of this method
 */
-(IBAction)segmentedControlAction:(id)sender;

/**
 *  Clears the contents of the outputTextView
 *
 *  @param sender The caller of this method
 */
-(IBAction)clearAction:(id)sender;

/**
 *  Shows the customPayloadTextView
 *
 *  @param sender The caller of this method
 */
-(IBAction)showCustomPayloadAction:(id)sender;

/**
 *  Shows the ResponseHeadersViewController
 *
 *  @param sender The caller of this method
 */
-(IBAction)showResponseHeadersAction:(id)sender;

/**
 *  Action to beging the parsing of JSON or csv
 *
 *  @param sender The caller of this method
 */
-(IBAction)parseAction:(id)sender;

/**
 *  Action that shows the JsonOutputViewController
 *
 *  @param sender The caller of this method
 */
-(void)showJsonOutputAction:(id)sender;

/**
 *  Action that shows the CsvOutputViewController
 *
 *  @param sender The caller of this method
 */
-(void)showCsvOutputAction:(id)sender;

@end
