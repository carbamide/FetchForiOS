//
//  FetchCell.m
//  Fetch for iOS
//
//  Created by Josh on 10/14/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "FetchCell.h"
#import "Parameters.h"
#import "Headers.h"
#import "SelectionViewController.h"

@interface FetchCell()
/**
 *  NSArray of common http headers
 */
@property (strong, nonatomic) NSArray *headerNames;

/**
 *  UIPopoverController that holds a SelectionViewController to select a header
 */
@property (strong, nonatomic) UIPopoverController *selectionPopover;

/**
 *  Determine the UITextField that called this method, then save that data to the current object, Header or Parameter
 *
 *  @param textField The caller of this method
 */
-(void)saveTextField:(UITextField *)textField;

@end

@implementation FetchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_headerNames) {
            _headerNames = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"HeaderNames" ofType:@"plist"]];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    
    [self setCurrentHeader:nil];
    [self setCurrentParameter:nil];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self cellType] == HeaderCell) {
        if (textField == [self nameTextField]) {
            SelectionViewController *viewController = [[SelectionViewController alloc] init];
            
            if (!_headerNames) {
                _headerNames = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"HeaderNames" ofType:@"plist"]];
            }
            
            [viewController setSender:textField];
            [viewController setDelegate:self];
            [viewController setDataSource:[self headerNames]];
            
            if (![self selectionPopover]) {
                [self setSelectionPopover:[[UIPopoverController alloc] initWithContentViewController:viewController]];
            }
            
            [[self selectionPopover] presentPopoverFromRect:[textField frame] inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self saveTextField:textField];
    
    [textField resignFirstResponder];
    
    [[self selectionPopover] dismissPopoverAnimated:YES];
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self saveTextField:textField];
    
    [textField resignFirstResponder];
    
    [[self selectionPopover] dismissPopoverAnimated:YES];

    return YES;
}

-(void)saveTextField:(UITextField *)textField
{
    [self setSelected:NO animated:YES];
    
    if (textField == [self nameTextField]) {
        if ([self currentHeader]) {
            [[self currentHeader] setName:[[self nameTextField] text]];
            [[self currentHeader] save];
        }
        else {
            [[self currentParameter] setName:[[self nameTextField] text]];
            [[self currentParameter] save];
        }
    }
    else {
        if ([self currentHeader]) {
            [[self currentHeader] setValue:[[self valueTextField] text]];
            [[self currentHeader] save];
        }
        else {
            [[self currentParameter] setValue:[[self valueTextField] text]];
            [[self currentParameter] save];
        }
    }
}
@end
