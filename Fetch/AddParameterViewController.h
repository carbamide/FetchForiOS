//
//  AddParameterViewController.h
//  Fetch
//
//  Created by Josh on 9/26/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Parameters;

@interface AddParameterViewController : UIViewController

@property (strong, nonatomic) Parameters *currentParameter;

@property (strong, nonatomic) IBOutlet UITextField *parameterValueTextField;
@property (strong, nonatomic) IBOutlet UITextField *parameterNameTextField;

-(IBAction)cancel:(id)sender;
-(IBAction)save:(id)sender;

@end
