//
//  JsonOutputViewController.m
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "JsonOutputViewController.h"
#import <RATreeView/RATreeView.h>
#import "JsonHandler.h"
#import "NodeObject.h"
#import "Constants.h"

@interface JsonOutputViewController () <RATreeViewDataSource, RATreeViewDelegate>
@property (weak, nonatomic) RATreeView *treeView;
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
    
    JsonHandler *tempData = [[JsonHandler alloc] init];
    
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

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 47;
}

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return (3 * [treeNodeInfo treeDepthLevel]);
}

- (BOOL)treeView:(RATreeView *)treeView shouldExpandItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return YES;
}

- (BOOL)treeView:(RATreeView *)treeView shouldItemBeExpandedAfterDataReload:(id)item treeDepthLevel:(NSInteger)treeDepthLevel
{
    return NO;
}

- (void)treeView:(RATreeView *)treeView willDisplayCell:(UITableViewCell *)cell forItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    if ([treeNodeInfo treeDepthLevel] == 0) {
        [cell setBackgroundColor:UIColorFromRGB(0xF7F7F7)];
    }
    else if ([treeNodeInfo treeDepthLevel] == 1) {
        [cell setBackgroundColor:UIColorFromRGB(0xD1EEFC)];
    }
    else if ([treeNodeInfo treeDepthLevel] == 2) {
        [cell setBackgroundColor:UIColorFromRGB(0xE0F8D8)];
    }
    
    if ([[[cell textLabel] text] isEqualToString:@""] && [[[cell detailTextLabel] text] isEqualToString:@""]) {
        [cell setBackgroundColor:UIColorFromRGB(0xF7F7F7)];
    }
}

#pragma mark -
#pragma mark - TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    UITableViewCell *cell = nil;
    
    if ([treeNodeInfo treeDepthLevel] == 0 && [[item children] count] > 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        
        [[cell textLabel] setText:[NSString stringWithFormat:@"%@", [item nodeTitle]]];
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%lu %@", (unsigned long)[[item children] count], ([[item children] count] > 1) ? @"objects" : @"object"]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if ([treeNodeInfo treeDepthLevel] == 0) {
            [[cell detailTextLabel] setTextColor:[UIColor blackColor]];
            
            if ([[[cell detailTextLabel] text] isEqualToString:@"(null)"]) {
                [[cell detailTextLabel] setText:@""];
            }
        }
    }
    else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        
        [[cell textLabel] setText:[NSString stringWithFormat:@"%@", [item nodeTitle]]];
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", [item nodeValue]]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if ([treeNodeInfo treeDepthLevel] == 0) {
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
    if (item == nil) {
        return [[self dataArray] count];
    }
    
    NodeObject *data = item;
    
    return [[data children] count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    NodeObject *data = item;
    
    if (item == nil) {
        return [self dataArray][index];
    }
    
    return [[data children] objectAtIndex:index];
}

@end
