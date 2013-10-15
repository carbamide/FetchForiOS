//
//  Constants.h
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

typedef enum CellType {
    HeaderCell = 0,
    ParameterCell = 1
} CellType;

// Dictionary Values
static NSString *const kInsertValue = @"Insert Value";
static NSString *const kInsertName = @"Insert Name";
static NSString *const kValue = @"Value";
static NSString *const kHeaderName = @"Header Name";
static NSString *const kParameterName = @"Parameter Name";

// Output Separators
static NSString *const kRequestSeparator = @"---------------------------------REQUEST--------------------------------------";
static NSString *const kResponseSeparator = @"---------------------------------RESPONSE------------------------------------";

// Output Colors
static NSString *const kSeparatorColor = @"separator_color";
static NSString *const kBackgroundColor = @"background_color";
static NSString *const kForegroundColor = @"foreground_color";
static NSString *const kSuccessColor = @"success_color";
static NSString *const kFailureColor = @"failure_color";

static NSString *const kProjectName = @"project_name";
static NSString *const kHeaders = @"headers";
static NSString *const kName = @"name";
static NSString *const kParameters = @"parameters";
static NSString *const kUrls = @"urls";
static NSString *const kUrl = @"url";
static NSString *const kMethod = @"method";
static NSString *const kCustomPayload = @"custom_payload";
static NSString *const kUrlDescription = @"url_description";
static NSString *const kJsonSyntaxHighlighting = @"json_syntax_highlighting";

// Notifications
static NSString *const RELOAD_PROJECT_TABLE = @"reload_project_table";
static NSString *const LOAD_URL = @"load_url";
static NSString *const ADD_HEADER = @"add_header";
static NSString *const ADD_PARAMETER = @"add_parameter";
static NSString *const RELOAD_HEADER_TABLE = @"reload_header_table";
static NSString *const RELOAD_PARAMETER_TABLE = @"reload_parameter_table";

// Segues
static NSString *const kAddParameterSegue = @"AddParameter";
static NSString *const kAddHeaderSegue = @"AddHeader";
static NSString *const kShowJsonOutputSegue = @"JSON Output";
static NSString *const kShowUrlsSegue = @"ShowUrls";