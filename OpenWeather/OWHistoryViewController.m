//
//  OWHistoryViewController.m
//  OpenWeather
//
//  Created by Harish Jambhale on 11/01/14.
//  Copyright (c) 2014 Harish Jambhale. All rights reserved.
//

#import "OWHistoryViewController.h"

@interface OWHistoryViewController ()

@end

@implementation OWHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Life cycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lblCityName.text = _cityName;
    self.weatherRecords = [[[OWCityManager sharedInstance] dictCities] objectForKey:_cityName];

    self.tableViewlWeatherHistory.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.weatherRecords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"cell";
    UITableViewCell *cell = [self.tableViewlWeatherHistory dequeueReusableCellWithIdentifier:identifier];
    
    UILabel *lblDate = (UILabel *)[cell viewWithTag:1];
    OWWeatherRecord *weatherRecord = [self.weatherRecords objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [lblDate setText:[formatter stringFromDate:weatherRecord.date]];
    
    UILabel *lblMaxTemp = (UILabel *)[cell viewWithTag:2];
    [lblMaxTemp setText:[weatherRecord.maxTemp stringValue]];
    
    UILabel *lblMinTemp = (UILabel *)[cell viewWithTag:3];
    [lblMinTemp setText:[weatherRecord.minTemp stringValue]];
    
    UILabel *lblHumidity = (UILabel *)[cell viewWithTag:4];
    [lblHumidity setText:[weatherRecord.humidity stringValue]];
    
    UILabel *lblPressure = (UILabel *)[cell viewWithTag:5];
    [lblPressure setText:[weatherRecord.pressure stringValue]];

    return cell;
}

@end
