//
//  FetchCell.h
//  Fetch for iOS
//
//  Created by Josh on 10/14/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@class Headers, Parameters;

@interface FetchCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *valueTextField;

@property (strong, nonatomic) Headers *currentHeader;
@property (strong, nonatomic) Parameters *currentParameter;

@property (nonatomic) CellType cellType;

@end
