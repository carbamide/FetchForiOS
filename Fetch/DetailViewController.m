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

@end

static int const kScrollMainViewForTextView = 200;
static float const kAnimationDuration = 0.3;
static int const kKeyboardHeight = 352;

NS_ENUM(NSInteger, CellTypeTag){
    kHeaderCell = 0,
    kParameterCell
};

@implementation DetailViewController

#pragma mark -
#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![self currentUrl]) {
        [[self urlTextField] setEnabled:NO];
        [[self urlDescriptionTextField] setEnabled:NO];
        [[self methodsButton] setEnabled:NO];
        [[self fetchButton] setEnabled:NO];
        [[self customPayloadSwitch] setEnabled:NO];
        [[self headersSegCont] setEnabled:NO];
        [[self parametersSegCont] setEnabled:NO];
        [[self jsonOutputButton] setEnabled:NO];
        [[self responseHeadersButton] setEnabled:NO];
        [[self clearButton] setEnabled:NO];
        
        [[self fetchActivityIndicator] setHidden:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUrl:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
    
    [[self urlDescriptionTextField] setPlaceholder:@"URL Description"];
    [[self urlTextField] setPlaceholder:@"URL"];
    
    [[[self outputTextView] layer] setCornerRadius:5];
    [[[self customPayloadTextView] layer] setCornerRadius:5];
    
    [self setHeadersDataSource:[NSMutableArray array]];
    [self setParametersDataSource:[NSMutableArray array]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUrl:) name:LOAD_URL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addHeader:) name:ADD_HEADER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addParameter:) name:ADD_PARAMETER object:nil];
    
    [self setTitle:@"Fetch for iOS"];
    
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] isInternetDown]) {
        [[[self navigationController] navigationBar] setBarTintColor:[UIColor redColor]];
        
        [self setTitle:[[self title] stringByAppendingString:@" - Internet Connection Down"]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:INTERNET_DOWN object:Nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *aNotification) {
        [[[self navigationController] navigationBar] setBarTintColor:[UIColor redColor]];
        
        [self setTitle:[[self title] stringByAppendingString:@" - Internet Connection Down"]];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:INTERNET_UP object:Nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *aNotification) {
        [[[self navigationController] navigationBar] setBarTintColor:[UIColor clearColor]];
        
        [self setTitle:[[self title] stringByReplacingOccurrencesOfString:@" - Internet Connection Down" withString:@""]];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    NSLog(@"%s", __FUNCTION__);
    
    [[self fetchActivityIndicator] setHidden:NO];
    [[self fetchActivityIndicator] startAnimating];
    [[self fetchButton] setHidden:YES];
    
    [[self responseHeadersButton] setEnabled:NO];
    
    [[self view] findAndResignFirstResponder];
    
    [[self clearButton] setEnabled:YES];
    
    if ([self addToUrlListIfUnique]) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSMutableString *parameters = [[NSMutableString alloc] init];
        
        if ([parameters length] > 0) {
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[self urlTextField] text], parameters]]];
        }
        else {
            [request setURL:[NSURL URLWithString:[[self urlTextField] text]]];
        }
        
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
        
        [self logReqest:request];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                  NSURLResponse *response,
                                                                  NSError *error) {
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
            NSInteger responseCode = [urlResponse statusCode];
            NSString *responseCodeString = [NSString stringWithFormat:@"Response - %li\n", (long)responseCode];
            
            [self appendToOutput:kResponseSeparator color:[UIColor blueColor]];
            [self setResponseDictionary:[urlResponse allHeaderFields]];
            
            if (NSLocationInRange(responseCode, NSMakeRange(200, (299 - 200)))) {
                [self appendToOutput:responseCodeString color:[UIColor greenColor]];
            }
            else {
                [self appendToOutput:responseCodeString color:[UIColor redColor]];
            }
            
            [self appendToOutput:[NSString stringWithFormat:@"%@", [urlResponse allHeaderFields]] color:[UIColor greenColor]];
            
            if (!error) {
                id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if (jsonData) {
                    [self setJsonData:jsonData];
                    
                    NSData *jsonHolder = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:nil];
                    
                    if (jsonHolder) {
                        [self appendToOutput:[[NSString alloc] initWithData:jsonHolder encoding:NSUTF8StringEncoding] color:[UIColor blackColor]];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[self fetchButton] setEnabled:YES];
                        [[self jsonOutputButton] setEnabled:YES];
                    });
                }
                else {
                    [self appendToOutput:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] color:[UIColor blackColor]];
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                         message:[error localizedDescription]
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil, nil];
                    
                    [errorAlert show];
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

-(IBAction)showJsonOutputAction:(id)sender
{
    JsonOutputViewController *viewController = [[JsonOutputViewController alloc] init];
    
    [viewController setJsonData:[self jsonData]];
    
    if ([[self responseHeadersPopover] isPopoverVisible]) {
        [[self responseHeadersPopover] dismissPopoverAnimated:YES];
    }
    
    [self setJsonPopover:[[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:viewController]]];
    
    [[self jsonPopover] presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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

#pragma mark -
#pragma mark - Methods

-(void)reloadUrl:(NSNotification *)aNotification
{
    NSLog(@"An update is happening!!!");
    
    if ([self currentUrl]) {
        [self loadUrl:[NSNotification notificationWithName:@"fake_notification" object:nil userInfo:@{@"url": [self currentUrl]}]];
    }
}

- (void)setDetailItem:(id)newDetailItem
{
    if (_currentProject != newDetailItem) {
        _currentProject = newDetailItem;
    }
    
    if ([self masterPopoverController]) {
        [[self masterPopoverController] dismissPopoverAnimated:YES];
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
    NSLog(@"%s", __FUNCTION__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[text stringByAppendingString:@"\n"]];
        
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
    NSLog(@"%s", __FUNCTION__);
    
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
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"The URL is invalid."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil, nil];
        
        [errorAlert show];
        
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
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:@"The HTTP method is invalid."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
            
            [errorAlert show];
            
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
    NSLog(@"%s", __FUNCTION__);
    
    [self appendToOutput:kRequestSeparator color:[UIColor blueColor]];
    
    [self appendToOutput:[request HTTPMethod] color:[UIColor greenColor]];
    [self appendToOutput:[NSString stringWithFormat:@"%@", [request allHTTPHeaderFields]] color:[UIColor greenColor]];
    [self appendToOutput:[[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] color:[UIColor greenColor]];
}

-(void)loadUrl:(NSNotification *)aNotification
{
    if ([self masterPopoverController]) {
        [[self masterPopoverController] dismissPopoverAnimated:YES];
    }
    
    [self setJsonData:nil];
    
    [[self jsonOutputButton] setEnabled:NO];
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

@end
