//
//  AddHeaderViewController.m
//  Fetch
//
//  Created by Josh on 9/26/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "AddHeaderViewController.h"
#import "SelectionViewController.h"
#import "Headers.h"
#import "Constants.h"

@interface AddHeaderViewController ()
@property (strong, nonatomic) NSArray *headerNames;
@end

@implementation AddHeaderViewController

#pragma mark -
#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![self headerNames]) {
        [self setHeaderNames:[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"HeaderNames" ofType:@"plist"]]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self currentHeader]) {
        [[self selectHeaderTypeButton] setTitle:[[self currentHeader] name] forState:UIControlStateNormal];
        [[self headerValueTextField] setText:[[self currentHeader] value]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark IBActions

-(IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)save:(id)sender
{
    Headers *tempHeader = nil;
    
    if ([self currentHeader]) {
        tempHeader = [self currentHeader];
    }
    else {
        tempHeader = [Headers create];
    }
    
    if ([[self customHeaderTextField] isHidden]) {
        [tempHeader setName:[[[self selectHeaderTypeButton] titleLabel] text]];
    }
    else {
        [tempHeader setName:[[self headerValueTextField] text]];
    }
    
    [tempHeader setValue:[[self headerValueTextField] text]];
    
    if ([self currentHeader]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_HEADER_TABLE object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_HEADER object:nil userInfo:@{@"header": tempHeader}];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)customHeaderAction:(id)sender
{
    if ([[self customHeaderTextField] isHidden]) {
        [[self customHeaderTextField] setHidden:NO];
        
        [[self customHeaderButton] setTitle:@"Default Header" forState:UIControlStateNormal];
    }
    else {
        [[self customHeaderTextField] setHidden:YES];
        
        [[self customHeaderButton] setTitle:@"Custom Header" forState:UIControlStateNormal];
        
        [[self customHeaderTextField] setText:@""];
    }
}

-(IBAction)selectHeaderAction:(id)sender
{
    SelectionViewController *viewController = [[SelectionViewController alloc] init];
    
    [viewController setSender:sender];
    [viewController setDelegate:self];
    [viewController setDataSource:[self headerNames]];
    
    if (![self selectionPopover]) {
        [self setSelectionPopover:[[UIPopoverController alloc] initWithContentViewController:viewController]];
    }
    
    [[self selectionPopover] presentPopoverFromRect:[sender frame] inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

@end
