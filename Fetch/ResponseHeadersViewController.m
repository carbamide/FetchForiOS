//
//  ResponseHeadersViewController.m
//  Fetch
//
//  Created by Josh on 9/29/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "ResponseHeadersViewController.h"

@interface ResponseHeadersViewController ()

@end

@implementation ResponseHeadersViewController

- (id)initWithStyle:(UITableViewStyle)style keysArray:(NSArray *)keys valuesArray:(NSArray *)values
{
    self = [super initWithStyle:style];
    if (self) {
        _keysDataSource = keys;
        _valuesDataSource = values;
        
        [self setPreferredContentSize:CGSizeMake(480, 320)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Response Headers"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self keysDataSource] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    [[cell textLabel] setText:[self keysDataSource][[indexPath row]]];
    [[cell detailTextLabel] setText:[self valuesDataSource][[indexPath row]]];
    
    return cell;
}

@end
