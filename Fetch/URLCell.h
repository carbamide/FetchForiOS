//
//  URLCell.h
//  Fetch for iOS
//
//  Created by Josh on 10/29/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Urls.h"

@interface URLCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *statusImage;
@property (strong, nonatomic) Urls *currentUrl;

-(void)setStatus:(URLStatus)status;

@end
