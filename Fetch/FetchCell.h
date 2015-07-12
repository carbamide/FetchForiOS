//
//  FetchCell.h
//  Fetch for iOS
//
//  Created by Josh on 10/14/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

@class Headers, Parameters;

/**
 *  FetchCell is the application's basic type of UITableViewCell.  It is used for displaying
 *  several types of information, such as Header objects and Parameter objects.
 *  
 *  FetchCell is a subclass of UITableViewCell and conforms to UITextFieldDelegate.
 */
@interface FetchCell : UITableViewCell <UITextFieldDelegate>

/**
 *  The delegate view controller of the FetchCell
 */
@property (weak) UIViewController *delegate;
/**
 *  The name of the Header or Parameter object
 */
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *nameTextField;

/**
 *  The value of the Header or Parameter object
 */
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *valueTextField;

/**
 *  Header object currently being displayed in this cell
 */
@property (strong, nonatomic) Headers *currentHeader;

/**
 *  Parameter object currently being displayed in this cell
 */
@property (strong, nonatomic) Parameters *currentParameter;

/**
 *  cellType determines what, a Header or a Parameter, is currently being shown in this cell
 */
@property (nonatomic) CellType cellType;

@end
