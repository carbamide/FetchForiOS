//
//  CsvOutputViewController.m
//  Fetch for iOS
//
//  Created by Josh on 11/2/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "CsvOutputViewController.h"

@interface CsvOutputViewController ()
@property (strong, nonatomic) NSArray *columnHeaders;

@end
@implementation CsvOutputViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setColumnHeaders:[[self dataSource][0] copy]];
    [[self dataSource] removeObjectAtIndex:0];
    
    [self setTitle:[NSString stringWithFormat:@"%ld Rows", (unsigned long)[[self dataSource] count]]];
    
    [[self spreadView] reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(IBAction)dismissSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfColumnsInSection:(NSInteger)section
{
    return [[self columnHeaders] count];
}

- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfRowsInSection:(NSInteger)section
{
    return [[self dataSource] count];
}

#pragma Cells
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    static NSString *cellIdentifier = @"Cell";
    
    MDSpreadViewCell *cell = [aSpreadView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MDSpreadViewCell alloc] initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if ([rowPath row] <= [[self dataSource] count] - 1) {
        NSArray *tempArray = [self dataSource][[rowPath row]];
        if ([columnPath row] <= [tempArray count] - 1) {
            NSString *stringValue = tempArray[[columnPath row]];
            
            [[cell textLabel] setText:stringValue];
        }
    }
    return cell;
}

- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    return [self columnHeaders][[columnPath column]];
}

- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath
{
    return [NSString stringWithFormat:@"Row %d", ([rowPath row] + 1)];
}

- (void)spreadView:(MDSpreadView *)aSpreadView didSelectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    [[self spreadView] deselectCellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath animated:YES];
}

- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willSelectCellForSelection:(MDSpreadViewSelection *)selection
{
    return [MDSpreadViewSelection selectionWithRow:[selection rowPath] column:[selection columnPath] mode:MDSpreadViewSelectionModeRowAndColumn];
}

@end
