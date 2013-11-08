//
//  CsvOutputViewController.m
//  Fetch for iOS
//
//  Created by Josh on 11/2/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "CsvOutputViewController.h"
#import "CHCSVParser.h"

@interface CsvOutputViewController ()
/**
 *  Column headers for the CSV
 */
@property (strong, nonatomic) NSArray *columnHeaders;

@property (strong, nonatomic) UIDocumentInteractionController *interactionController;

@end
@implementation CsvOutputViewController

#pragma mark -
#pragma mark - View Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setColumnHeaders:[self dataSource][0]];
    [[self dataSource] removeObjectAtIndex:0];

    [self setTitle:[NSString stringWithFormat:@"%ld Rows", (unsigned long)[[self dataSource] count]]];
    
    [[self spreadView] reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self spreadView] setOpaque:NO];
    [[self spreadView] setBackgroundColor:[UIColor clearColor]];
    [[self view] setOpaque:NO];
}

-(IBAction)dismissSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)share:(id)sender
{
    [self exportToCSVFile];
    
    _interactionController = [[UIDocumentInteractionController alloc] init];
    [_interactionController setURL:[NSURL fileURLWithPath:[[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"temp.csv"]]];
    [_interactionController setUTI:@"public.comma-separated-values-text"];
    [_interactionController setDelegate:self];
    [_interactionController presentOpenInMenuFromBarButtonItem:sender animated:YES];
}

#pragma mark -
#pragma mark - MDSpreadView DataSource and Delegate

-(CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowAtIndexPath:(MDIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfColumnsInSection:(NSInteger)section
{
    return [[self columnHeaders] count];
}

- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfRowsInSection:(NSInteger)section
{
    return [[self dataSource] count];
}

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
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [[cell backgroundView] setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    return [self columnHeaders][[columnPath column]];
}

- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath
{
    return [NSString stringWithFormat:@"Row %lu", (unsigned long)([rowPath row] + 1)];
}

- (void)spreadView:(MDSpreadView *)aSpreadView didSelectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath
{
    [[self spreadView] deselectCellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath animated:YES];
}

- (MDSpreadViewSelection *)spreadView:(MDSpreadView *)aSpreadView willSelectCellForSelection:(MDSpreadViewSelection *)selection
{
    return [MDSpreadViewSelection selectionWithRow:[selection rowPath] column:[selection columnPath] mode:MDSpreadViewSelectionModeRowAndColumn];
}

-(void)exportToCSVFile
{
    CHCSVWriter *writer = [[CHCSVWriter alloc] initForWritingToCSVFile:[[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"temp.csv"]];
    
    [writer writeLineOfFields:[self columnHeaders]];
    [writer finishLine];
    
    for (NSArray *array in [self dataSource]) {
        [writer writeLineOfFields:array];
        [writer finishLine];
    }
    
    [writer closeStream];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
