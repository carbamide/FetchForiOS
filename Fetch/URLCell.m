//
//  URLCell.m
//  Fetch for iOS
//
//  Created by Josh on 10/29/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#import "URLCell.h"

@implementation URLCell

-(void)setStatus:(URLStatus)status
{
    if (status == URLUp) {
        [[self statusImage] setImage:[[UIImage imageNamed:@"Good"] stretchableImageWithLeftCapWidth:1 topCapHeight:1]];
    }
    else {
        [[self statusImage] setImage:[[UIImage imageNamed:@"Bad"] stretchableImageWithLeftCapWidth:1 topCapHeight:1]];
    }
}

@end
