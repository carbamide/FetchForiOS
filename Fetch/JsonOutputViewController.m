//
//  JsonOutputViewController.m
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "JsonOutputViewController.h"
#import <RATreeView.h>
#import "DataHandler.h"
#import "NodeObject.h"
#import "Constants.h"

@interface JsonOutputViewController () <RATreeViewDataSource, RATreeViewDelegate>
/**
 *  RATreeView that displays the JSON in an awesome, awesome way.
 */
@property (weak, nonatomic) RATreeView *treeView;

/**
 *  Datasource for the RATreeView
 */
@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation JsonOutputViewController

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
    
    [self setPreferredContentSize:CGSizeMake(480, 320)];
    
    [self setTitle:@"JSON Representation"];
    
    if ([[self jsonData] isKindOfClass:[NSArray class]]) {
        [self setJsonData:@{@"Root": [self jsonData]}];
    }
    
    DataHandler *tempData = [[DataHandler alloc] init];
    
    [tempData addEntries:[self jsonData]];
    
    [self setDataArray:[tempData dataSource]];
    
    RATreeView *treeView = [[RATreeView alloc] initWithFrame:[[self view] frame]];
    
    [treeView setDelegate:self];
    [treeView setDataSource:self];
    [treeView setSeparatorStyle:RATreeViewCellSeparatorStyleSingleLine];
    
    [treeView reloadData];
    [treeView setBackgroundColor:UIColorFromRGB(0xF7F7F7)];
    
    [self setTreeView:treeView];
    [[self view] addSubview:treeView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self treeView] setFrame:[[self view] bounds]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - TreeView Delegate methods

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item treeNodeInfo:(id)treeNodeInfo
{
    return 47;
}

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(id)treeNodeInfo
{
    return (3 * [treeView levelForCellForItem:treeNodeInfo]);
}

- (BOOL)treeView:(RATreeView *)treeView shouldExpandItem:(id)item treeNodeInfo:(id)treeNodeInfo
{
    return YES;
}

- (BOOL)treeView:(RATreeView *)treeView shouldItemBeExpandedAfterDataReload:(id)item treeDepthLevel:(NSInteger)treeDepthLevel
{
    return NO;
}

- (void)treeView:(RATreeView *)treeView willDisplayCell:(UITableViewCell *)cell forItem:(id)item treeNodeInfo:(id)treeNodeInfo
{
    NSInteger treeDepthLevel = [treeView levelForCellForItem:treeNodeInfo];
    
    if (treeDepthLevel == 0) {
        [cell setBackgroundColor:UIColorFromRGB(0xF7F7F7)];
    }
    else if (treeDepthLevel == 1) {
        [cell setBackgroundColor:UIColorFromRGB(0xD1EEFC)];
    }
    else if (treeDepthLevel == 2) {
        [cell setBackgroundColor:UIColorFromRGB(0xE0F8D8)];
    }
    
    if ([[[cell textLabel] text] isEqualToString:@""] && [[[cell detailTextLabel] text] isEqualToString:@""]) {
        [cell setBackgroundColor:UIColorFromRGB(0xF7F7F7)];
    }
}

#pragma mark -
#pragma mark - TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item
{
    UITableViewCell *cell = nil;
    
    static NSString *TopLevelCellIdentifer = @"TopLevelCell";
    static NSString *ChildCellIdentifer = @"ChildCellIdentifer";
    
    NSInteger treeDepthLevel = [treeView levelForCellForItem:item];

    if (treeDepthLevel == 0 && [[item children] count] > 0) {
        cell = [treeView dequeueReusableCellWithIdentifier:TopLevelCellIdentifer];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TopLevelCellIdentifer];
        }
        
        [[cell textLabel] setText:[NSString stringWithFormat:@"%@", [item nodeTitle]]];
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%lu %@", (unsigned long)[[item children] count], ([[item children] count] == 1) ? @"element" : @"elements"]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if (treeDepthLevel == 0) {
            [[cell detailTextLabel] setTextColor:[UIColor blackColor]];
            
            if ([[[cell detailTextLabel] text] isEqualToString:@"(null)"]) {
                [[cell detailTextLabel] setText:@""];
            }
        }
    }
    else {
        cell = [treeView dequeueReusableCellWithIdentifier:ChildCellIdentifer];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ChildCellIdentifer];
        }
        
        if ([item isKindOfClass:[NSArray class]]) {
            [[cell textLabel] setText:[NSString stringWithFormat:@"Dictionary - %lu %@", (unsigned long)[item count], [item count] == 1 ? @"element" : @"elements"]];
        }
        else {
            [[cell textLabel] setText:[NSString stringWithFormat:@"%@", [item nodeTitle]]];
        }
        
        if ([item isKindOfClass:[NSArray class]]) {
            [[cell detailTextLabel] setText:[NSString string]];
        }
        else {
            [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", [item nodeValue]]];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if (treeDepthLevel == 0) {
            [[cell detailTextLabel] setTextColor:[UIColor blackColor]];
            
            if ([[[cell detailTextLabel] text] isEqualToString:@"(null)"]) {
                [[cell detailTextLabel] setText:@""];
            }
        }
    }
    
    if (cell) {
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:17]];
    }
    
    return cell;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    id tempObject = item;
    
    if (!tempObject) {
        return [[self dataArray] count];
    }
    else {
        if ([tempObject isKindOfClass:[NSArray class]]) {
            return [tempObject count];
        }
        else {
            return [[tempObject children] count];
        }
    }
    return 0;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    id tempObject = item;
    
    if (!tempObject) {
        return [self dataArray][index];
    }
    else {
        if ([tempObject isKindOfClass:[NSArray class]]) {
            return tempObject[index];
        }
        return [tempObject children][index];
    }
    
    return nil;
}

@end
