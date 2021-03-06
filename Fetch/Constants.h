//
//  Constants.h
//  Fetch
//
//  Created by Josh on 9/25/13.
//  Copyright (c) 2013 Jukaela Enterprises. All rights reserved.
//

// Defines
#define kAppDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define IPAD_KEYBOARD_HEIGHT 352

// Cell Types
typedef enum CellType {
    HeaderCell = 0,
    ParameterCell = 1
} CellType;

// URL Status
typedef enum URLStatus {
    URLUp = 0,
    URLDown
} URLStatus;


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
#define kSeparatorColor [UIColor colorWithRed:0.194759 green:0.33779 blue:1 alpha:1]
#define kBackgroundColor [UIColor colorWithRed:0.813159 green:0.811473 blue:0.829574 alpha:1]
#define kForegroundColor [UIColor colorWithRed:0.248374 green:0.23825 blue:0.242783 alpha:1]
#define kSuccessColor [UIColor colorWithRed:0.144757 green:0.639582 blue:0.18152 alpha:1]
#define kFailureColor [UIColor colorWithRed:0.680571 green:0.0910357 blue:0.111851 alpha:1]

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
static NSString *const INTERNET_DOWN = @"internet_down";
static NSString *const INTERNET_UP = @"internet_up";
static NSString *const SHOW_PARSE_ACTION = @"show_parse_action";

// Segues
static NSString *const kAddParameterSegue = @"AddParameter";
static NSString *const kAddHeaderSegue = @"AddHeader";
static NSString *const kShowJsonOutputSegue = @"JSON Output";
static NSString *const kShowUrlsSegue = @"ShowUrls";
static NSString *const kShowCsvViewer = @"CSVViewer";