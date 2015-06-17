//
//  MasterViewController.m
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "ProjectListViewController.h"
#import "DetailViewController.h"
#import "Projects.h"
#import "UrlListViewController.h"
#import "Constants.h"
#import "ProjectHandler.h"
#import "AppDelegate.h"

@interface ProjectListViewController ()
/**
 *  NSMutableArray that holds the list of projects
 */
@property (strong, nonatomic) NSMutableArray *projectList;

/**
 *  The currently selected Project object
 */
@property (strong, nonatomic) Projects *currentProject;

/**
 *  A temporary store
 */
@property (strong, nonatomic) Projects *tempProject;

/**
 *  Edit the name of the Project object
 *
 *  @param project The Project to edit the name of.
 */
-(void)editProjectName:(Projects *)project;

/**
 *  Being insertion process of new Project
 *
 *  @param sender The caller of this method.
 */
- (void)insertNewObject:(id)sender;

/**
 *  Gesture recognizer for long press on the table view.  This gesture is a UILongPressGesture.
 *  This handler begins the share / export process.
 *
 *  @param gestureRecognizer UIGestureRecognizer that called this action.
 */
-(void)shareAction:(UIGestureRecognizer *)gestureRecognizer;

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

/**
 *  Handle iCloud notification
 *
 *  @param aNotification The notification to handle
 */
-(void)iCloudHandler:(NSNotification *)aNotification;

/**
 *  Reload the RELOAD_TABLE notification
 *
 *  @param aNotification The notification to handle
 */
-(void)reloadProjectTable:(NSNotification *)aNotification;

@end

@implementation ProjectListViewController

#pragma mark -
#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [self setClearsSelectionOnViewWillAppear:NO];
    [self setPreferredContentSize:CGSizeMake(320, 600)];
    
    [self setProjectList:[NSMutableArray array]];
        
    [super awakeFromNib];
    
//this is a comment.
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] isInternetDown]) {
        [[[self navigationController] navigationBar] setBarTintColor:[UIColor redColor]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetDown:) name:INTERNET_DOWN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetUp:) name:INTERNET_UP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudHandler:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProjectTable:) name:RELOAD_PROJECT_TABLE object:nil];
    
    [self reloadProjectTable:nil];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    
    [[self navigationItem] setRightBarButtonItem:addButton];
    
    [self setDetailViewController:(DetailViewController *)[[[[self splitViewController] viewControllers] lastObject] topViewController]];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INTERNET_DOWN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INTERNET_UP object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_PROJECT_TABLE object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kShowUrlsSegue]) {
        UrlListViewController *tempViewController = [segue destinationViewController];
        
        [tempViewController setCurrentProject:[self currentProject]];
    }
}

#pragma mark -
#pragma mark - Methods

-(void)editProjectName:(Projects *)project
{
    UIAlertView *projectNameAlert = [[UIAlertView alloc] initWithTitle:[project name]
                                                               message:@"New name?"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Update", nil];
    
    [projectNameAlert setTag:65];
    [projectNameAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    [[projectNameAlert textFieldAtIndex:0] setPlaceholder:[project name]];
    
    [projectNameAlert show];
}

- (void)insertNewObject:(id)sender
{
    UIAlertView *projectNameAlert = [[UIAlertView alloc] initWithTitle:@"New Project"
                                                               message:@"Project name?"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Create", nil];
    
    [projectNameAlert setTag:64];
    [projectNameAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [projectNameAlert show];
}


-(void)shareAction:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPathOfSelectedRow = [[self tableView] indexPathForRowAtPoint:[gestureRecognizer locationInView:[self tableView]]];
        
        if (!indexPathOfSelectedRow) {
            return;
        }
        
        Projects *tempProject = [self projectList][[indexPathOfSelectedRow row]];
        
        NSURL *exportedURL = [ProjectHandler exportProject:tempProject];
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[exportedURL] applicationActivities:nil];
        
        [activityViewController setExcludedActivityTypes:@[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter]];
        
        if (![self activityPopoverController]) {
            [self setActivityPopoverController:[[UIPopoverController alloc] initWithContentViewController:activityViewController]];
        }
        
        [[self activityPopoverController] setContentViewController:activityViewController];
        
        [[self activityPopoverController] presentPopoverFromRect:[[gestureRecognizer view] frame] inView:[self tableView] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void)internetDown:(NSNotification *)aNotification
{
    [[[self navigationController] navigationBar] setBarTintColor:[UIColor redColor]];
}

-(void)internetUp:(NSNotification *)aNotification
{
    [[[self navigationController] navigationBar] setBarTintColor:[UIColor clearColor]];
}

-(void)iCloudHandler:(NSNotification *)aNotification
{
    [[self projectList] removeAllObjects];
    
    [[Projects all] each:^(Projects *object) {
        [[self projectList] addObject:object];
    }];
    
    [[self tableView] reloadData];
}

-(void)reloadProjectTable:(NSNotification *)aNotification
{
    [[self projectList] removeAllObjects];
    
    [[Projects all] each:^(Projects *object) {
        [[self projectList] addObject:object];
    }];
    
    [[self tableView] reloadData];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 64) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Create"]) {
            Projects *tempProject = [Projects create];
            
            UITextField *tempTextField = [alertView textFieldAtIndex:0];
            
            [tempProject setName:[tempTextField text]];
            [tempProject save];
            
            [[self projectList] addObject:tempProject];
            
            [[self tableView] beginUpdates];
            [[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([[self projectList] count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[self tableView] endUpdates];
        }
    }
    else if ([alertView tag] == 65) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Update"]) {
            Projects *tempProject = [self tempProject];
            
            UITextField *tempTextField = [alertView textFieldAtIndex:0];
            
            [tempProject setName:[tempTextField text]];
            [tempProject save];
            
            [[self projectList] replaceObjectAtIndex:[[self projectList] indexOfObject:[self tempProject]] withObject:tempProject];
            
            [[self tableView] reloadData];
        }
    }
}

#pragma mark -
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self projectList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[MSCMoreOptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Projects *project = [self projectList][[indexPath row]];
    
    [[cell textLabel] setText:[project name]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setDelegate:self];
    [[cell imageView] setImage:[UIImage imageNamed:@"Project"]];
    
    [cell addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shareAction:)]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Projects *tempProject = [self projectList][[indexPath row]];
        
        [[self projectList] removeObject:tempProject];
        
        [tempProject delete];
        
        [[self tableView] beginUpdates];
        [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [[self tableView] endUpdates];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Projects *tempProject = [self projectList][[indexPath row]];
    
    [self setCurrentProject:tempProject];
    [[self detailViewController] setCurrentProject:tempProject];
    
    [self performSegueWithIdentifier:kShowUrlsSegue sender:nil];
}

#pragma mark -
#pragma mark MSCMoreOptionsMoreOptionsTableViewCell Delegate

- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath
{
    Projects *tempProject = [self projectList][[indexPath row]];
    
    [self setTempProject:tempProject];
    UIAlertController *editNameActionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [editNameActionSheet addAction:[UIAlertAction actionWithTitle:@"Edit Name..." style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self editProjectName:[self tempProject]];
    }]];
    
    [editNameActionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [[editNameActionSheet popoverPresentationController] setSourceView:[self tableView]];
    [[editNameActionSheet popoverPresentationController] setSourceRect:[[[self tableView] cellForRowAtIndexPath:indexPath] frame]];
    
    [self presentViewController:editNameActionSheet animated:YES completion:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"More";
}

@end
