//
//  OWViewController.h
//  OpenWeather
//
//  Created by Harish Jambhale on 03/01/14.
//  Copyright (c) 2014 Harish Jambhale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "OWWeatherRecord.h"
#import "OWCityAnnotation.h"
#import "OWHistoryViewController.h"
#import "OWCityManager.h"

@interface OWMainViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *txtCityName;
@property (nonatomic) IBOutlet UIButton* btnGo;
@property (nonatomic) IBOutlet MKMapView* mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnPrevLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnNextLocation;


- (IBAction)goToInputLocation:(id)sender;
- (IBAction)textFieldValueChanged:(UITextField *)textField;
- (IBAction)textFieldFocusLost:(UITextField *)textField;
- (IBAction)done:(UIStoryboardSegue *)segue;

- (IBAction)showPrevLocation:(id)sender;
- (IBAction)showNextLocation:(id)sender;


@end
