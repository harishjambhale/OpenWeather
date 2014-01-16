//
//  OWHistoryViewController.h
//  OpenWeather
//
//  Created by Harish Jambhale on 11/01/14.
//  Copyright (c) 2014 Harish Jambhale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWCityManager.h"
#import "OWWeatherRecord.h"

@interface OWHistoryViewController : UIViewController <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *lblCityName;
@property (weak, nonatomic) IBOutlet UITableView *tableViewlWeatherHistory;
@property (nonatomic) NSString* cityName;
@property (nonatomic) NSArray *weatherRecords;

@end
