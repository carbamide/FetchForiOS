//
//  UrlListViewController.m
//  Fetch
//
//  Created by Josh on 9/26/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "UrlListViewController.h"
#import "Projects.h"
#import "Urls.h"
#import "Constants.h"

@interface UrlListViewController ()

@property (strong, nonatomic) NSMutableArray *urlList;

@end

@implementation UrlListViewController

#pragma mark - 
#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [self setClearsSelectionOnViewWillAppear:NO];
    [self setPreferredContentSize:CGSizeMake(320, 600)];
    
    [self setUrlList:[NSMutableArray array]];
    
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    for (Urls *tempUrl in [[self currentProject] urls]) {
        [[self urlList] addObject:tempUrl];
    }
    
    [[self tableView] reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:RELOAD_PROJECT_TABLE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *aNotification) {
        [[self urlList] removeAllObjects];
        
        for (Urls *tempUrl in [[self currentProject] urls]) {
            [[self urlList] addObject:tempUrl];
        }
        
        [[self tableView] reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

-(IBAction)addUrl:(id)sender
{
    if ([self currentProject]) {
        Urls *tempUrl = [Urls create];
        
        [tempUrl setUrlDescription:@"New URL"];
        
        [[self currentProject] addUrlsObject:tempUrl];
        
        [[self currentProject] save];
        
        [[self urlList] addObject:tempUrl];
    
        [[self tableView] reloadData];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self urlList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Urls *tempUrl = [self urlList][[indexPath row]];
    
    if ([[tempUrl urlDescription] length] > 0) {
        [[cell textLabel] setText:[tempUrl urlDescription]];
    }
    else {
        [[cell textLabel] setText:[tempUrl url]];
    }
    
    [[cell imageView] setImage:[UIImage imageNamed:@"URL"]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Urls *tempUrl = [self urlList][[indexPath row]];
        
        [[self urlList] removeObject:tempUrl];
        
        [tempUrl delete];
        
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
    Urls *tempUrl = [self urlList][[indexPath row]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_URL object:nil userInfo:@{@"url": tempUrl}];
}

@end
