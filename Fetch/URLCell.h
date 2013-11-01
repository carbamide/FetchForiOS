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

/**
 *  URLCells are a subclass of UITableViewCell that are responsible for displaying the data contained
 *  in Url objects.  URLCells also display the reachability status of the Url object contained therein.
 */
@interface URLCell : UITableViewCell

/**
 *  The current reachability status of the Url being display in the cell
 */
@property (strong, nonatomic) IBOutlet UIImageView *statusImage;

/**
 *  The URL object being displayed in the cell
 */
@property (strong, nonatomic) Urls *currentUrl;

/**
 *  Method that sets the current reachability status to be displayed in statusImage.
 *  This status is also saved to the currentUrl so that when the Url object is next
 *  displayed, a fetch doesn't have to happen before a status is available to display.
 *
 *  @param status The current URLStatus of the currentUrl Url object
 */
-(void)setStatus:(URLStatus)status;

@end
