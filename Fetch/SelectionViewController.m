//
//  SelectionViewController.m
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "SelectionViewController.h"
#import "DetailViewController.h"

@interface SelectionViewController ()

@end

@implementation SelectionViewController

#pragma mark -
#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setPreferredContentSize:CGSizeMake(220, ([[self dataSource] count] * 44))];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self dataSource] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [[cell textLabel] setText:[self dataSource][[indexPath row]]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *button = nil;
    UITextField *textField = nil;
    
    if ([[self sender] isKindOfClass:[UIButton class]]) {
        button = [self sender];
    }
    else {
        textField = [self sender];
    }
    
    if (button) {
        [button setTitle:[self dataSource][[indexPath row]] forState:UIControlStateNormal];
    }
    else {
        [textField setText:[self dataSource][[indexPath row]]];
        [textField resignFirstResponder];
    }
    
    [[[self delegate] selectionPopover] dismissPopoverAnimated:YES];
}

@end
