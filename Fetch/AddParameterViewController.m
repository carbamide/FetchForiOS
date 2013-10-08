//
//  AddParameterViewController.m
//  Fetch
//
//  Created by Josh on 9/26/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "AddParameterViewController.h"
#import "Parameters.h"
#import "Constants.h"

@interface AddParameterViewController ()

@end

@implementation AddParameterViewController

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self currentParameter]) {
        [[self parameterNameTextField] setText:[[self currentParameter] name]];
        [[self parameterValueTextField] setText:[[self currentParameter] value]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 
#pragma mark - IBActions

-(IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)save:(id)sender
{
    Parameters *tempParameter = nil;
    
    if ([self currentParameter]) {
        tempParameter = [self currentParameter];
    }
    else {
        tempParameter = [Parameters create];
    }
    
    [tempParameter setName:[[self parameterNameTextField] text]];
    [tempParameter setValue:[[self parameterValueTextField] text]];
    
    
    if ([self currentParameter]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_PARAMETER_TABLE object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_PARAMETER object:nil userInfo:@{@"parameter": tempParameter}];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
