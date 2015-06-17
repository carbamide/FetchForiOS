//
//  DetailViewController.m
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "DetailViewController.h"
#import "SelectionViewController.h"
#import "Projects.h"
#import "Headers.h"
#import "Urls.h"
#import "Parameters.h"
#import "Constants.h"
#import "UIView+FindAndResignFirstResponder.h"
#import "JsonOutputViewController.h"
#import "ResponseHeadersViewController.h"
#import "FetchCell.h"
#import "AppDelegate.h"
#import "CHCSVParser.h"
#import "CsvOutputViewController.h"

@interface DetailViewController ()
/**
 *  UIPopoverController that holds a reference to the UISplitView's 0th panel
 */
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

/**
 *  Data source for the headersTableView
 */
@property (strong, nonatomic) NSMutableArray *headersDataSource;

/**
 *  Data source for the paramsTableView
 */
@property (strong, nonatomic) NSMutableArray *parametersDataSource;

/**
 *  List of URLs contained in the currently selected Project
 */
@property (strong, nonatomic) NSMutableArray *urlList;

/**
 *  The URL object currently being displayed
 */
@property (strong, nonatomic) Urls *currentUrl;

/**
 *  Holder for JSON data returned from a fetch
 */
@property (strong, nonatomic) id jsonData;

/**
 *  NSDictionary that holds the response from the server when a fetch occurs
 */
@property (strong, nonatomic) NSDictionary *responseDictionary;

/**
 * JSON Data returns from fetch action.  This is either an NSDictionary or NSArray
 */
@property (strong, nonatomic) id responseData;

/**
 *  Reference to the csv row data
 */
@property (nonatomic) NSArray *csvRows;

/**
 *  Reference to parseActionSheet
 */
@property (strong, nonatomic) UIAlertController *parseActionSheet;

/**
 *  Maximize gesture for outputTextView
 */
@property (strong, nonatomic) UITapGestureRecognizer *maximizeGesture;

/**
 *  Minimize gesture for outputTextView
 */
@property (strong, nonatomic) UITapGestureRecognizer *minimizeGesture;

/**
 *  Reload URL notification handler
 *
 *  @param aNotification The notification that was broadcast
 */
-(void)reloadUrl:(NSNotification *)aNotification;

/**
 *  Sets the current Project
 *
 *  @param currentProject The Project object to set as the currentProject
 */
-(void)setCurrentProject:(Projects *)currentProject;

/**
 *  Convienence method to provide an NSArray of common HTTP methods
 *
 *  @return NSArray of common HTTP methods.
 */
-(NSArray *)httpMethods;

/**
 *  Appends the specified text, in the specified color to the outputTextView
 *
 *  @param text  The text to append to the outputTextView
 *  @param color The request color of the text
 */
- (void)appendToOutput:(NSString *)text color:(UIColor *)color;

/**
 *  Check if URL is unique and perform several saving methods
 *
 *  @return Returns YES if the URL is uniquen in the Project, NO if it's not
 */
-(BOOL)addToUrlListIfUnique;

/**
 *  Logs the specified NSMutableURLRequest to the outputTextView
 *
 *  @param request The NSMutableURLRequest to log to the outputTextView
 */
-(void)logReqest:(NSMutableURLRequest *)request;

/**
 *  Load URL Notification Handler
 *
 *  @param aNotification The notification to handle
 */
-(void)loadUrl:(NSNotification *)aNotification;

/**
 *  Add Header notification handler
 *
 *  @param aNotification The Notification to handle
 */
-(void)addHeader:(NSNotification *)aNotification;

/**
 *  Add parameter notification handler
 *
 *  @param aNotification The notification to handle
 */
-(void)addParameter:(NSNotification *)aNotification;

/**
 *  Show the CsvOutputViewController
 *
 *  @param sender The caller of this method
 */
-(void)showCsvOutputAction:(id)sender;

/**
 *  Expand the outputTextView to the full size of the view's frame.
 *
 *  @param gestureRecognizer The UITapGestureRecognizer that called this method
 */
-(void)expandOutputTextView:(UITapGestureRecognizer *)gestureRecognizer;

/**
 *  Minimize the outputTextView back to it's original size
 *
 *  @param sender The caller of this method
 */
-(void)minimizeOutputTextView:(id)sender;

/**
 *  Handle the internet down notification
 *
 *  @param aNotification The notification that is sent
 */
-(void)internetDown:(NSNotification *)aNotification;

/**
 *  Handle the internet up notification
 *
 *  @param aNotification The notification that is sent
 */
-(void)internetUp:(NSNotification *)aNotification;

@end

static int const kScrollMainViewForTextView = 200;
static float const kAnimationDuration = 0.3;
#define kLandscapeOutputViewRect CGRectMake(14, 575, 669, 135)
#define kPortraitOutputViewRect CGRectMake(14, 831, 734, 135)

NS_ENUM(NSInteger, CellTypeTag){
    kHeaderCell = 0,
    kParameterCell
};

@implementation DetailViewController

#pragma mark -
#pragma mark - Lifecycle

-(void)setupUserInterface
{
    [[self outputTextView] setEditable:NO];
    [[self outputTextView] setPrimaryHighlightColor:UIColorFromRGB(0xfff51d)];
    [[self outputTextView] setSecondaryHighlightColor:UIColorFromRGB(0xfffa86)];
    
    //Meh - I don't know about all this.  I might change it back.
    [[[self outputTextView] layer] setBorderWidth:1];
    [[[self outputTextView] layer] setBorderColor:[[[kAppDelegate window] tintColor] CGColor]];
    [[self outputTextView] setBackgroundColor:[UIColor whiteColor]];
    
    [[[self customPayloadTextView] layer] setBorderWidth:1];
    [[[self customPayloadTextView] layer] setBorderColor:[[[kAppDelegate window] tintColor] CGColor]];
    [[self customPayloadTextView] setBackgroundColor:[UIColor whiteColor]];
    
    if (![self currentUrl]) {
        [[self urlTextField] setEnabled:NO];
        [[self urlDescriptionTextField] setEnabled:NO];
        [[self methodsButton] setEnabled:NO];
        [[self fetchButton] setEnabled:NO];
        [[self customPayloadSwitch] setEnabled:NO];
        [[self headersSegCont] setEnabled:NO];
        [[self parametersSegCont] setEnabled:NO];
        [[self parseButton] setEnabled:NO];
        [[self responseHeadersButton] setEnabled:NO];
        [[self clearButton] setEnabled:NO];
        
        [[self fetchActivityIndicator] setHidden:YES];
    }
    
    if (![self searchBar]) {
        [self setSearchBar:[[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, 704, 44)]];
        
        [[self searchBar] setBarStyle:UIBarStyleDefault];
        [[self searchBar] setDelegate:self];
        [[self searchBar] setAlpha:0.0];
        [[self searchBar] setUserInteractionEnabled:NO];
        
        [[self view] addSubview:[self searchBar]];
    }
    
    [[self urlDescriptionTextField] setPlaceholder:@"URL Description"];
    [[self urlTextField] setPlaceholder:@"URL"];
    
    [[[self outputTextView] layer] setCornerRadius:5];
    [[[self customPayloadTextView] layer] setCornerRadius:5];
    
    [[self customPayloadTextView] setPlaceholder:@"Custom Payload"];
    
    [self setTitle:@"Fetch for iOS"];
    
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] isInternetDown]) {
        [[[self navigationController] navigationBar] setBarTintColor:[UIColor redColor]];
        
        [self setTitle:[[self title] stringByAppendingString:@" - Internet Connection Down"]];
    }
}

-(void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUrl:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUrl:) name:LOAD_URL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addHeader:) name:ADD_HEADER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addParameter:) name:ADD_PARAMETER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseAction:) name:SHOW_PARSE_ACTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetDown:) name:INTERNET_DOWN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetUp:) name:INTERNET_UP object:nil];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUserInterface];
    
    _maximizeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandOutputTextView:)];
    [_maximizeGesture setNumberOfTapsRequired:2];
    
    [[self outputTextView] addGestureRecognizer:_maximizeGesture];
    
    [self setupNotifications];
    
    [self setHeadersDataSource:[NSMutableArray array]];
    [self setParametersDataSource:[NSMutableArray array]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kShowCsvViewer]) {
        UINavigationController *navController = [segue destinationViewController];
        CsvOutputViewController *csvViewController = (CsvOutputViewController *)[navController topViewController];
        
        [csvViewController setDataSource:[[self csvRows] mutableCopy]];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOAD_URL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ADD_HEADER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ADD_PARAMETER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHOW_PARSE_ACTION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INTERNET_DOWN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INTERNET_UP object:nil];
}

#pragma mark -
#pragma mark - IBActions

-(IBAction)methodsAction:(id)sender
{
    SelectionViewController *viewController = [[SelectionViewController alloc] init];
    
    [viewController setSender:sender];
    [viewController setDelegate:self];
    [viewController setDataSource:[self httpMethods]];
    
    if (![self selectionPopover]) {
        [self setSelectionPopover:[[UIPopoverController alloc] initWithContentViewController:viewController]];
    }
    
    [[self selectionPopover] presentPopoverFromRect:[sender frame] inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(IBAction)fetchAction:(id)sender
{
    [self setJsonData:nil];
    
    [[self view] bringSubviewToFront:[self fetchActivityIndicator]];
    
    [[self fetchActivityIndicator] setHidden:NO];
    [[self fetchActivityIndicator] startAnimating];
    [[self fetchButton] setHidden:YES];
    
    [[self responseHeadersButton] setEnabled:NO];
    
    [[self view] findAndResignFirstResponder];
    
    [[self clearButton] setEnabled:YES];
    
    if ([self addToUrlListIfUnique]) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSMutableString *parameters = [[NSMutableString alloc] init];
        
        [request setHTTPMethod:[[[self methodsButton] titleLabel] text]];
        
        for (Headers *tempHeader in [self headersDataSource]) {
            [request setValue:[tempHeader value] forHTTPHeaderField:[tempHeader name]];
        }
        
        if ([[self customPayloadSwitch] isOn]) {
            [request setHTTPBody:[[[self customPayloadTextView] text] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else {
            for (Parameters *tempParam in [self parametersDataSource]) {
                if (tempParam == [[self parametersDataSource] first]) {
                    [parameters appendString:[NSString stringWithFormat:@"?%@=%@", [tempParam name], [tempParam value]]];
                }
                else {
                    [parameters appendString:[NSString stringWithFormat:@"&%@=%@", [tempParam name], [tempParam value]]];
                }
            }
        }
        
        if ([parameters length] > 0) {
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[self urlTextField] text], parameters]]];
        }
        else {
            [request setURL:[NSURL URLWithString:[[self urlTextField] text]]];
        }
        
        [self logReqest:request];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                       NSURLResponse *response,
                                                                                       NSError *error) {
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
            NSInteger responseCode = [urlResponse statusCode];
            NSString *responseCodeString = [NSString stringWithFormat:@"Response - %li\n", (long)responseCode];
            
            [self appendToOutput:kResponseSeparator color:kSeparatorColor];
            [self setResponseDictionary:[urlResponse allHeaderFields]];
            
            if (NSLocationInRange(responseCode, NSMakeRange(200, (299 - 200)))) {
                [self appendToOutput:responseCodeString color:kSuccessColor];
            }
            else {
                [self appendToOutput:responseCodeString color:kFailureColor];
            }
            
            [self appendToOutput:[NSString stringWithFormat:@"%@", [urlResponse allHeaderFields]] color:kSuccessColor];
            
            if (!error) {
                [self setResponseData:data];
                
                id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if (jsonData) {
                    [self setJsonData:jsonData];
                    
                    NSData *jsonHolder = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:nil];
                    
                    if (jsonHolder) {
                        [self appendToOutput:[[NSString alloc] initWithData:jsonHolder encoding:NSUTF8StringEncoding] color:kForegroundColor];
                    }
                }
                else {
                    [self appendToOutput:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] color:kForegroundColor];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[self fetchButton] setEnabled:YES];
                    [[self parseButton] setEnabled:YES];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                                      message:[error localizedDescription]
                                                                                               preferredStyle:UIAlertControllerStyleAlert];
                    
                    [errorAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                    
                    [self presentViewController:errorAlert animated:YES completion:nil];
                });
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self responseHeadersButton] setEnabled:YES];
                [[self fetchActivityIndicator] setHidden:YES];
                [[self fetchActivityIndicator] stopAnimating];
                [[self fetchButton] setHidden:NO];
            });
        }] resume];
    }
}

-(IBAction)segmentedControlAction:(id)sender
{
    if (sender == [self headersSegCont]) {
        if ([sender selectedSegmentIndex] == 0) {
            Headers *tempHeader = [Headers create:@{@"name": @"", @"value": @""}];
            [tempHeader save];
            
            [[self currentUrl] addHeadersObject:tempHeader];
            [[self currentUrl] save];
            
            [[self headersDataSource] addObject:tempHeader];
            
            [[self headersTableView] beginUpdates];
            [[self headersTableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[[self headersDataSource] indexOfObject:tempHeader] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[self headersTableView] endUpdates];
        }
        else {
            NSIndexPath *indexPath = [[self headersTableView] indexPathForSelectedRow];
            
            if (!indexPath) {
                return;
            }
            
            Headers *tempHeader = [self headersDataSource][[indexPath row]];
            
            [tempHeader delete];
            
            [[self headersDataSource] removeObjectAtIndex:[indexPath row]];
            
            [[self headersTableView] beginUpdates];
            [[self headersTableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[self headersTableView] endUpdates];
        }
    }
    else if (sender == [self parametersSegCont]) {
        if ([sender selectedSegmentIndex] == 0) {
            Parameters *tempParam = [Parameters create:@{@"name": @"", @"value": @""}];
            [tempParam save];
            
            [[self currentUrl] addParametersObject:tempParam];
            [[self currentUrl] save];
            
            [[self parametersDataSource] addObject:tempParam];
            
            [[self parametersTableView] beginUpdates];
            [[self parametersTableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[[self parametersDataSource] indexOfObject:tempParam] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[self parametersTableView] endUpdates];
        }
        else {
            NSIndexPath *indexPath = [[self parametersTableView] indexPathForSelectedRow];
            
            if (!indexPath) {
                return;
            }
            
            Parameters *tempParam = [self parametersDataSource][[indexPath row]];
            
            [tempParam delete];
            
            [[self parametersDataSource] removeObjectAtIndex:[indexPath row]];
            
            [[self parametersTableView] beginUpdates];
            [[self parametersTableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[self parametersTableView] endUpdates];
        }
    }
}

-(IBAction)clearAction:(id)sender
{
    [[self outputTextView] setText:@""];
    
    [[self clearButton] setEnabled:NO];
}

-(IBAction)showCustomPayloadAction:(id)sender
{
    if ([[self customPayloadSwitch] isOn]) {
        [[self customPayloadTextView] setHidden:NO];
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [[self customPayloadTextView] setAlpha:1.0];
            [[self parametersSegCont] setAlpha:0.0];
        }];
    }
    else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [[self customPayloadTextView] setAlpha:0.0];
            [[self parametersSegCont] setAlpha:1.0];
        } completion:^(BOOL finished) {
            [[self customPayloadTextView] setHidden:YES];
        }];
    }
}

-(IBAction)showResponseHeadersAction:(id)sender
{
    __block NSMutableArray *keysArray = [NSMutableArray array];
    __block NSMutableArray *valuesArray = [NSMutableArray array];
    
    [[self responseDictionary] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [keysArray addObject:key];
        [valuesArray addObject:obj];
    }];
    
    ResponseHeadersViewController *headersViewController = [[ResponseHeadersViewController alloc] initWithStyle:UITableViewStylePlain keysArray:keysArray valuesArray:valuesArray];
    
    if ([[self jsonPopover] isPopoverVisible]) {
        [[self jsonPopover] dismissPopoverAnimated:YES];
    }
    
    if (![self responseHeadersPopover]) {
        [self setResponseHeadersPopover:[[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:headersViewController]]];
    }
    
    [[self responseHeadersPopover] presentPopoverFromBarButtonItem:[self responseHeadersButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(IBAction)parseAction:(id)sender
{
    if ([[self presentedViewController] isKindOfClass:[UIAlertController class]]) {
        if (_parseActionSheet) {
            [_parseActionSheet dismissViewControllerAnimated:YES completion:nil];
            
            return;
        }
    }
    
    _parseActionSheet = [UIAlertController alertControllerWithTitle:nil
                                                            message:nil
                                                     preferredStyle:UIAlertControllerStyleActionSheet];
    
    [[_parseActionSheet popoverPresentationController] setBarButtonItem:sender];
    [_parseActionSheet setModalPresentationStyle:UIModalPresentationPopover];
    
    [_parseActionSheet addAction:[UIAlertAction actionWithTitle:@"CSV" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showCsvOutputAction:nil];
    }]];
    
    [_parseActionSheet addAction:[UIAlertAction actionWithTitle:@"JSON" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showJsonOutputAction:nil];
        
    }]];
    
    
    [self presentViewController:_parseActionSheet animated:YES completion:nil];
}

#pragma mark -
#pragma mark - Methods

-(void)reloadUrl:(NSNotification *)aNotification
{
    if ([self currentUrl]) {
        [self loadUrl:[NSNotification notificationWithName:@"fake_notification" object:nil userInfo:@{@"url": [self currentUrl]}]];
    }
}

-(void)setCurrentProject:(Projects *)currentProject
{
    _currentProject = currentProject;
    
    [self setTitle:[currentProject name]];
}

-(NSArray *)httpMethods
{
    return @[@"GET", @"POST", @"PUT", @"DELETE"];
}

- (void)appendToOutput:(NSString *)text color:(UIColor *)color
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[text stringByAppendingString:@"\n"]];
        
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier New" size:14] range:NSMakeRange(0, [text length])];
        
        if (color) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [text length])];
        }
        
        [[[self outputTextView] textStorage] appendAttributedString:attributedString];
        [[self outputTextView] scrollRangeToVisible:NSMakeRange([[[self outputTextView] text] length], 0)];
        
        [[self clearButton] setEnabled:YES];
    });
}

-(BOOL)addToUrlListIfUnique
{
    if ([[self urlTextField] text] == nil || [[[self urlTextField] text] isEqualToString:@""]) {
        return NO;
    }
    
    BOOL validPrefix = NO;
    
    NSArray *validUrlPrefixes = @[@"http", @"https"];
    
    for (NSString *prefix in validUrlPrefixes) {
        if ([[[self urlTextField] text] hasPrefix:prefix]) {
            validPrefix = YES;
        }
    }
    
    if (!validPrefix) {
        [[self fetchActivityIndicator] setHidden:YES];
        [[self fetchActivityIndicator] stopAnimating];
        [[self fetchButton] setHidden:NO];
        
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                            message:@"The URL is invalid."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        [errorAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:errorAlert animated:YES completion:nil];
        
        return NO;
    }
    
    BOOL addURL = YES;
    
    for (Urls *tempURL in [[self currentProject] urls]) {
        if ([[tempURL url] isEqualToString:[[self urlTextField] text]]) {
            addURL = NO;
            
            break;
        }
    }
    
    if (addURL) {
        Urls *tempUrl = [self currentUrl];
        
        NSInteger method;
        NSString *methodText = [[[self methodsButton] titleLabel] text];
        
        if ([methodText isEqualToString:@"GET"]) {
            method = 0;
        }
        else if ([methodText isEqualToString:@"POST"]) {
            method = 1;
        }
        else if ([methodText isEqualToString:@"PUT"]) {
            method = 2;
        }
        else if ([methodText isEqualToString:@"DELETE"]) {
            method = 3;
        }
        else {
            [[self fetchActivityIndicator] setHidden:YES];
            [[self fetchActivityIndicator] stopAnimating];
            [[self fetchButton] setHidden:NO];
            
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                message:@"The HTTP Method is invalid."
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            
            [errorAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            
            [self presentViewController:errorAlert animated:YES completion:nil];
            
            return NO;
        }
        
        [tempUrl setMethod:[NSNumber numberWithInteger:method]];
        [tempUrl setUrl:[[self urlTextField] text]];
        [tempUrl setUrlDescription:[[self urlDescriptionTextField] text]];
        
        [self setCurrentUrl:tempUrl];
        
        if ([self currentProject]) {
            [[self currentProject] addUrlsObject:tempUrl];
            
            [[self currentProject] save];
        }
        else {
            [tempUrl save];
        }
        
        [[self urlList] removeAllObjects];
        
        for (Urls *url in [[self currentProject] urls]) {
            [[self urlList] addObject:url];
        }
    }
    
    return YES;
}

-(void)logReqest:(NSMutableURLRequest *)request
{
    [self appendToOutput:[NSString stringWithFormat:@"%@", [request URL]] color:kForegroundColor];
    [self appendToOutput:kRequestSeparator color:kSeparatorColor];
    [self appendToOutput:[request HTTPMethod] color:kSuccessColor];
    [self appendToOutput:[NSString stringWithFormat:@"%@", [request allHTTPHeaderFields]] color:kSuccessColor];
    [self appendToOutput:[[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] color:kSuccessColor];
}

-(void)loadUrl:(NSNotification *)aNotification
{
    [self minimizeOutputTextView:nil];
    
    if ([self masterPopoverController]) {
        [[self masterPopoverController] dismissPopoverAnimated:YES];
    }
    
    [self setJsonData:nil];
    
    [[self parseButton] setEnabled:NO];
    [[self responseHeadersButton] setEnabled:NO];
    
    [[self headersDataSource] removeAllObjects];
    [[self parametersDataSource] removeAllObjects];
    
    Urls *url = [aNotification userInfo][@"url"];
    
    [self setCurrentUrl:url];
    
    if ([self currentUrl]) {
        [[self urlTextField] setEnabled:YES];
        [[self urlDescriptionTextField] setEnabled:YES];
        
        [[self methodsButton] setEnabled:YES];
        [[self fetchButton] setEnabled:YES];
        
        [[self customPayloadSwitch] setEnabled:YES];
        
        [[self headersSegCont] setEnabled:YES];
        [[self parametersSegCont] setEnabled:YES];
    }
    
    [[self urlTextField] setText:[url url]];
    [[self urlDescriptionTextField] setText:[url urlDescription]];
    
    if ([[url method] isEqualToNumber:@0]) {
        [[self methodsButton] setTitle:@"GET" forState:UIControlStateNormal];
    }
    else if ([[url method] isEqualToNumber:@1]) {
        [[self methodsButton] setTitle:@"POST" forState:UIControlStateNormal];
    }
    else if ([[url method] isEqualToNumber:@2]) {
        [[self methodsButton] setTitle:@"PUT" forState:UIControlStateNormal];
    }
    else if ([[url method] isEqualToNumber:@3]) {
        [[self methodsButton] setTitle:@"DELETE" forState:UIControlStateNormal];
    }
    
    for (Headers *tempHeader in [[self currentUrl] headers]) {
        [[self headersDataSource] addObject:tempHeader];
    }
    
    for (Parameters *tempParamater in [[self currentUrl] parameters]) {
        [[self parametersDataSource] addObject:tempParamater];
    }
    
    if ([[[self currentUrl] customPayload] length] > 0) {
        [[self customPayloadSwitch] setOn:YES animated:YES];
        [[self customPayloadTextView] setText:[[self currentUrl] customPayload]];
        
        [[self customPayloadTextView] setHidden:NO];
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [[self customPayloadTextView] setAlpha:1.0];
            [[self parametersSegCont] setAlpha:0.0];
        }];
    }
    else {
        [[self customPayloadSwitch] setOn:NO animated:YES];
        [[self customPayloadTextView] setText:@""];
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [[self customPayloadTextView] setAlpha:0.0];
            [[self parametersSegCont] setAlpha:1.0];
        }];
        
        [[self customPayloadTextView] setHidden:YES];
    }
    
    [[self parametersTableView] reloadData];
    [[self headersTableView] reloadData];
}

-(void)addHeader:(NSNotification *)aNotification
{
    Headers *tempHeader = [aNotification userInfo][@"header"];
    
    [tempHeader save];
    
    [[self currentUrl] addHeadersObject:tempHeader];
    [[self currentUrl] save];
    
    [[self headersDataSource] addObject:tempHeader];
    
    [[self headersTableView] beginUpdates];
    [[self headersTableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([[self headersDataSource] count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self headersTableView] endUpdates];
}

-(void)addParameter:(NSNotification *)aNotification
{
    Parameters *tempParameter = [aNotification userInfo][@"parameter"];
    
    [tempParameter save];
    
    [[self currentUrl] addParametersObject:tempParameter];
    [[self currentUrl] save];
    
    [[self parametersDataSource] addObject:tempParameter];
    
    [[self parametersTableView] beginUpdates];
    [[self parametersTableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([[self parametersDataSource] count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self parametersTableView] endUpdates];
}

-(void)showJsonOutputAction:(id)sender
{
    if ([self jsonData]) {
        JsonOutputViewController *viewController = [[JsonOutputViewController alloc] init];
        
        [viewController setJsonData:[self jsonData]];
        
        if ([[self responseHeadersPopover] isPopoverVisible]) {
            [[self responseHeadersPopover] dismissPopoverAnimated:YES];
        }
        
        [self setJsonPopover:[[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:viewController]]];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [[self jsonPopover] presentPopoverFromBarButtonItem:[self parseButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        });
    }
    else {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                            message:@"The data is not in the correct format."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        [errorAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:errorAlert animated:YES completion:nil];
    }
    
}

-(void)showCsvOutputAction:(id)sender
{
    NSMutableArray *rows = [[NSArray arrayWithContentsOfString:[[NSString alloc] initWithData:[self responseData] encoding:NSUTF8StringEncoding] options:CHCSVParserOptionsSanitizesFields|CHCSVParserOptionsStripsLeadingAndTrailingWhitespace] mutableCopy];
    
    for (NSArray *tempArray in rows) {
        if ([tempArray count] == 0) {
            [rows removeObject:tempArray];
        }
    }
    
    if (rows) {
        [self setCsvRows:rows];
        
        [self performSegueWithIdentifier:kShowCsvViewer sender:self];
    }
    else {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                            message:@"The data is not in the correct format."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        [errorAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:errorAlert animated:YES completion:nil];
    }
}

-(void)expandOutputTextView:(UITapGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        [[self searchBar] setAlpha:1.0];
        
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            [[self outputTextView] setFrame:CGRectMake(0, 0, 703, 768)];
        }
        else {
            [[self outputTextView] setFrame:CGRectMake(0, 0, 768, 1024)];
        }
    } completion:^(BOOL finished) {
        UIEdgeInsets tempInsets = UIEdgeInsetsMake(108, 0.0, 44, 0.0);
        
        [[self outputTextView] setContentInset:tempInsets];
        [[self outputTextView] setScrollIndicatorInsets:tempInsets];
        
        [[self searchBar] setUserInteractionEnabled:YES];
        
        [[self outputTextView] removeGestureRecognizer:_maximizeGesture];
        
        if (!_minimizeGesture) {
            _minimizeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(minimizeOutputTextView:)];
            [_minimizeGesture setNumberOfTapsRequired:2];
        }
        
        [[self outputTextView] addGestureRecognizer:_minimizeGesture];
        
        [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(minimizeOutputTextView:)]];
    }];
}

-(void)minimizeOutputTextView:(id)sender
{
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        [[self searchBar] setAlpha:0];
        
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            [[self outputTextView] setFrame:kLandscapeOutputViewRect];
        }
        else {
            [[self outputTextView] setFrame:kPortraitOutputViewRect];
        }
    } completion:^(BOOL finished) {
        UIEdgeInsets tempInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 0.0);
        
        [[self outputTextView] setContentInset:tempInsets];
        [[self outputTextView] setScrollIndicatorInsets:tempInsets];
        
        [[self searchBar] setUserInteractionEnabled:NO];
        
        [[self outputTextView] removeGestureRecognizer:_minimizeGesture];
        
        if (!_maximizeGesture) {
            _maximizeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandOutputTextView:)];
            
            [_maximizeGesture setNumberOfTapsRequired:2];
        }
        
        [[self outputTextView] addGestureRecognizer:_maximizeGesture];
        [[self outputTextView] scrollRangeToVisible:NSMakeRange([[[self outputTextView] text] length], 0)];
        
        [[self navigationItem] setLeftBarButtonItem:nil];
    }];
}

-(void)internetDown:(NSNotification *)aNotification
{
    [[[self navigationController] navigationBar] setBarTintColor:[UIColor redColor]];
    
    [self setTitle:[[self title] stringByAppendingString:@" - Internet Connection Down"]];
}

-(void)internetUp:(NSNotification *)aNotification
{
    [[[self navigationController] navigationBar] setBarTintColor:[UIColor clearColor]];
    
    [self setTitle:[[self title] stringByReplacingOccurrencesOfString:@" - Internet Connection Down" withString:@""]];
}

#pragma mark -
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == [self headersTableView]) {
        return [[self headersDataSource] count];
    }
    else {
        return [[self parametersDataSource] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FetchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[FetchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == [self headersTableView]) {
        Headers *tempHeader = [self headersDataSource][[indexPath row]];
        
        [[cell nameTextField] setText:[tempHeader name]];
        [[cell nameTextField] setPlaceholder:@"Header Name"];
        
        [[cell valueTextField] setText:[tempHeader value]];
        [[cell valueTextField] setPlaceholder:@"Header Value"];
        
        [cell setCellType:HeaderCell];
        
        [[cell valueTextField] setTag:kHeaderCell];
        [[cell nameTextField] setTag:kHeaderCell];
    }
    else {
        Parameters *tempParameter = [self parametersDataSource][[indexPath row]];
        
        [[cell nameTextField] setText:[tempParameter name]];
        [[cell nameTextField] setPlaceholder:@"Parameter Name"];
        
        [[cell valueTextField] setText:[tempParameter value]];
        [[cell valueTextField] setPlaceholder:@"Parameter Value"];
        
        [cell setCellType:ParameterCell];
        
        [[cell valueTextField] setTag:kParameterCell];
        [[cell nameTextField] setTag:kParameterCell];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (tableView == [self headersTableView]) {
            Headers *tempHeader = [self headersDataSource][[indexPath row]];
            
            [tempHeader delete];
            
            [[self headersDataSource] removeObject:tempHeader];
            
            [[self headersTableView] beginUpdates];
            [[self headersTableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[self headersTableView] endUpdates];
        }
        else {
            Parameters *tempParameter = [self parametersDataSource][[indexPath row]];
            
            [tempParameter delete];
            
            [[self parametersDataSource] removeObject:tempParameter];
            
            [[self parametersTableView] beginUpdates];
            [[self parametersTableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[self parametersTableView] endUpdates];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == [self headersTableView]) {
        return @"Headers";
    }
    else {
        return @"Parameters";
    }
}

#pragma mark -
#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField tag] == kParameterCell) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [[self view] setBounds:CGRectOffset([[self view] bounds], 0, kScrollMainViewForTextView)];
        }];
    }
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField tag] == kParameterCell) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [[self view] setBounds:CGRectOffset([[self view] bounds], 0, -kScrollMainViewForTextView)];
        }];
    }
    else if (textField == [self urlDescriptionTextField]) {
        [[self currentUrl] setUrlDescription:[textField text]];
        [[self currentUrl] save];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_PROJECT_TABLE object:nil];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == [self urlTextField] || textField == [self urlDescriptionTextField]) {
        [self fetchAction:textField];
    }
    
    [[self view] findAndResignFirstResponder];
    
    return NO;
}


#pragma mark -
#pragma mark - UISplitViewDelegate

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    [barButtonItem setTitle:@"Projects"];
    
    [[self navigationItem] setLeftBarButtonItem:barButtonItem animated:YES];
    
    [self setMasterPopoverController:popoverController];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [[self navigationItem] setLeftBarButtonItem:nil animated:YES];
    
    [self setMasterPopoverController:nil];
}

#pragma mark -
#pragma mark - UITextViewDelegate

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [[self view] setBounds:CGRectOffset([[self view] bounds], 0, kScrollMainViewForTextView)];
    }];
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [[self view] setBounds:CGRectOffset([[self view] bounds], 0, -kScrollMainViewForTextView)];
    }];
    
    return YES;
}

#pragma mark -
#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (!searchText || [searchText isEqualToString:@""]) {
        [_outputTextView resetSearch];
        
        return;
    }
    
    [_outputTextView scrollToString:searchText searchOptions:NSRegularExpressionCaseInsensitive];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    return;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_outputTextView scrollToString:[searchBar text] searchOptions:NSRegularExpressionCaseInsensitive];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setText:nil];
    [_outputTextView resetSearch];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_outputTextView setFrame:CGRectMake(self.outputTextView.frame.origin.x,
                                             self.outputTextView.frame.origin.y,
                                             self.outputTextView.frame.size.width,
                                             self.outputTextView.frame.size.height - IPAD_KEYBOARD_HEIGHT)];
    } completion:nil];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_outputTextView setFrame:CGRectMake(self.outputTextView.frame.origin.x,
                                             self.outputTextView.frame.origin.y,
                                             self.outputTextView.frame.size.width,
                                             self.outputTextView.frame.size.height + IPAD_KEYBOARD_HEIGHT)];
    } completion:nil];
    
    return YES;
}
@end
