//
//  OWViewController.m
//  OpenWeather
//
//  Created by Harish Jambhale on 03/01/14.
//  Copyright (c) 2014 Harish Jambhale. All rights reserved.
//

#import "OWMainViewController.h"
#define kOWHistoryURL @"http://api.openweathermap.org/data/2.5/history/city"
#define kOWAppID @"c37ec7c59d25a3ad821793f7172b84a6"

@interface OWMainViewController ()


@end

@implementation OWMainViewController

UIActivityIndicatorView   *aSpinner;
NSMutableArray *citiesToShowOnMap;
int currentLocationIndex;
dispatch_queue_t queue;

#pragma mark - Life cycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    aSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                UIActivityIndicatorViewStyleGray];
    
    aSpinner.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:aSpinner];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    //show user location on map initially, now that MapKit detects user location, we don't have to do any explicit coding for it.
    //Otherwise, we can get the user location usig CLLocationManager

    
    if (self.tableView) {
        self.tableView.dataSource = self;
    }
    
    queue = dispatch_queue_create("com.example.owviewcontroller.queue", DISPATCH_QUEUE_SERIAL);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue called");
    
    if ([[segue identifier] isEqualToString:@"ShowCityHistory"]) {
        
        OWHistoryViewController *historyViewController = (OWHistoryViewController *)segue.destinationViewController;
        
        OWCityAnnotation *city = ((MKAnnotationView *)sender).annotation;
        historyViewController.cityName = city.title;
    }
}

#pragma mark - IBAction methods
- (IBAction)goToInputLocation:(id)sender
{
    NSLog(@"In goToInputLocation");
    
    citiesToShowOnMap = [[self.txtCityName.text componentsSeparatedByString:@","] mutableCopy];
    NSMutableArray *invalidCities = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < citiesToShowOnMap.count; i++) {
        NSString *cityName = [citiesToShowOnMap objectAtIndex:i];
        NSString *trimmedCityName = [cityName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([trimmedCityName isEqualToString:@""]) {
            NSLog(@"index %i is empty string", i);
            [invalidCities addObject:[citiesToShowOnMap objectAtIndex:i]];
        }
        
    }
    
    [citiesToShowOnMap removeObjectsInArray:invalidCities];
    
    if (citiesToShowOnMap.count < 1) {
        return;
    }
    
    self.btnGo.enabled = NO;
    [aSpinner startAnimating];

    currentLocationIndex = 0;

    [self showLocationForCurrentIndex];
    [self getHistory:citiesToShowOnMap];
}


- (IBAction)textFieldValueChanged:(UITextField *)textField
{
    NSLog(@"In textFieldShouldEndEditing");
    if ([textField isEqual:self.txtCityName]) {
        [self toggleGoButton];
    }
}

- (IBAction)textFieldFocusLost:(UITextField *)textField
{
    NSLog(@"In textFieldFocusLost");
    [textField resignFirstResponder];
}


- (IBAction)done:(UIStoryboardSegue *)segue {
    NSLog(@"Popping back to this view controller!");
    // reset UI elements etc here
}

- (IBAction)showPrevLocation:(id)sender
{
    
    currentLocationIndex--;
    [self showLocationForCurrentIndex];
    
    if (self.tableView) {
        [self.tableView reloadData];
    }
}
- (IBAction)showNextLocation:(id)sender
{
    currentLocationIndex++;
    [self showLocationForCurrentIndex];

    if (self.tableView) {
        [self.tableView reloadData];
    }
}

#pragma mark - Private methods
- (void) getHistory:(NSArray *)cities
{
    [[OWCityManager sharedInstance].dictCities removeAllObjects];
    
    [cities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *cityName = (NSString *)obj;
        
        cityName = [cityName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *encodedCityName = [cityName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSLog(@"cityName after encoding : %@", encodedCityName);
        
        dispatch_async(queue, ^{ 
            NSLog(@"Starting Download in background");
            NSString *strCityUrl = [NSString stringWithFormat:@"%@?q=%@&APPID=%@", kOWHistoryURL, encodedCityName, kOWAppID];
            NSURL *url = [NSURL URLWithString:strCityUrl];
            
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            NSError *error;
            NSMutableDictionary *jsonDictionary;
            
            if (data) {
                jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            }
            
            NSMutableArray *weatherRecords = [[NSMutableArray alloc] init];
            
            if (!jsonDictionary || error)
            {
                NSLog(@"It seems that some error has occurred: %@, %@", jsonDictionary, error.description);
            }
            else
            {
                NSArray *listItems =[jsonDictionary objectForKey:@"list"];
                NSLog(@"JSON : %@", jsonDictionary);
                NSLog(@"list Items : %@", listItems);
                
                [listItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSDictionary *oneDayRecord = obj;
                    OWWeatherRecord *weatherRecord = [[OWWeatherRecord alloc] init];
                    
                    weatherRecord.strCityName = [(NSDictionary *)[oneDayRecord objectForKey:@"city"] objectForKey:@"name"];
                    
                    NSTimeInterval recordDateInTimeInterval = [[oneDayRecord objectForKey:@"dt"] doubleValue];
                    weatherRecord.date = [NSDate dateWithTimeIntervalSince1970:recordDateInTimeInterval];
                    
                    
                    NSDictionary *mainDictionary = [oneDayRecord objectForKey:@"main"];
                    
                    weatherRecord.temp = (NSNumber *)[mainDictionary objectForKey:@"temp"];
                    weatherRecord.pressure = (NSNumber *)[mainDictionary objectForKey:@"pressure"];
                    
                    weatherRecord.maxTemp = (NSNumber *)[mainDictionary objectForKey:@"temp_max"];
                    weatherRecord.minTemp = (NSNumber *)[mainDictionary objectForKey:@"temp_min"];
                    
                    weatherRecord.humidity = (NSNumber *)[mainDictionary objectForKey:@"humidity"];
                    [weatherRecords addObject:weatherRecord];
                }];
                
                [[OWCityManager sharedInstance].dictCities setObject:weatherRecords forKey:cityName];
                NSLog(@"Added City : %@ with records : %lu", cityName, (unsigned long)weatherRecords.count);
                
            }
            if([cityName isEqual:[cities objectAtIndex:0]])
                [self updateUI:(!error && jsonDictionary)];
        });
    }];

    
}

-(void)updateUI:(BOOL)isResponseReceived
{
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(mainQueue, ^{
        NSLog(@"updating ui on main queue");
        
        [aSpinner stopAnimating];
        self.btnGo.enabled = YES;
        
        if (!isResponseReceived) {
            NSString *strMessage = NSLocalizedString(@"The weather data could not be retreived.", nil);
            NSString *strCancel = NSLocalizedString(@"OK", nil);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:strMessage delegate:nil cancelButtonTitle:strCancel otherButtonTitles:nil, nil];
            
            [alert show];
        }
        
        if (self.tableView) {
            [self.tableView reloadData];
        }
        
    });
}

-(void) showLocationOnMapWithIndex:(int)locationIndex withCoordinate:(CLLocationCoordinate2D)location
{
    //Show location
    [self.mapView removeAnnotations:[self.mapView annotations]];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 1000 * 1000, 1000 * 1000);
    [self.mapView setRegion:region animated:YES];
    
    //Add annotation to the location
    NSString *cityName = [[citiesToShowOnMap objectAtIndex:locationIndex] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    OWCityAnnotation *weatherCity = [[OWCityAnnotation alloc] initWithCoordinates:location placeName:cityName description:@""];

    [self.mapView addAnnotation:weatherCity];
    
    //toggle next and prev buttons according to location index
    [self togglePrevAndNextButtons];
    
}

-(void)togglePrevAndNextButtons
{
    //If there are no more locations, then disable navigation buttons
    if (citiesToShowOnMap.count <= 1) {
        self.btnPrevLocation.hidden = YES;
        self.btnNextLocation.hidden = YES;
        return;
    }

    //For First locationn
    if (currentLocationIndex == 0) {
        self.btnPrevLocation.hidden = YES;
        self.btnNextLocation.hidden = NO;
    }
    //for last location
    else if(currentLocationIndex >= citiesToShowOnMap.count - 1)
    {
        self.btnPrevLocation.hidden = NO;
        self.btnNextLocation.hidden = YES;
    }
    else
    {
        self.btnPrevLocation.hidden = NO;
        self.btnNextLocation.hidden = NO;
    }

}

-(void)showLocationForCurrentIndex
{
    NSString *cityName = [citiesToShowOnMap objectAtIndex:currentLocationIndex];
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    __block CLLocationCoordinate2D location;
    [geoCoder geocodeAddressString:cityName completionHandler:^(NSArray* placemarks, NSError* error){
        for (CLPlacemark* aPlacemark in placemarks)
        {
            // Process the placemark.
            location = aPlacemark.location.coordinate;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showLocationOnMapWithIndex:currentLocationIndex withCoordinate:location];
            });
        }
    }];
}

- (void)showUserLocation:(MKUserLocation *)userLocation
{
    CLGeocoder* geoCoder = [[CLGeocoder alloc] init];
    
    NSLog(@"New userLocation : %@", userLocation);
    [geoCoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
        
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            return;
            
        }
        
        if(placemarks && placemarks.count > 0)
            
        {
            //do something
            CLPlacemark *topResult = [placemarks objectAtIndex:0];
            self.txtCityName.text = [topResult locality];
            citiesToShowOnMap = [[NSMutableArray alloc] initWithObjects:self.txtCityName.text, nil];
            currentLocationIndex = 0;
            [self getHistory:citiesToShowOnMap];
            [self showLocationForCurrentIndex];
        }
    }];
}

- (void) toggleGoButton
{
    NSString *trimmedCitiesName = [self.txtCityName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([trimmedCitiesName isEqualToString:@""]) {
        self.btnGo.enabled = NO;
        self.txtCityName.text = @"";
    }
    else {
        self.btnGo.enabled = YES;
    }
}

#pragma mark - MKMapViewDelegate methods
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self showUserLocation:userLocation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    static NSString *identifier = @"WeatherCity";
    if ([annotation isKindOfClass:[OWCityAnnotation class]])
    {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                /*
                UIButton *btnTemp = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
                btnTemp.backgroundColor = [UIColor lightGrayColor];
                [btnTemp setTitle:@"20,10" forState:UIControlStateNormal];
                btnTemp.tag = 1;
                annotationView.leftCalloutAccessoryView = btnTemp;*/
                
                UIButton *btnHistory = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
                btnHistory.backgroundColor = [UIColor lightGrayColor];
                [btnHistory setTitle:@"History" forState:UIControlStateNormal];
                btnHistory.tag = 2;
                annotationView.rightCalloutAccessoryView = btnHistory;

            }

            
        } else
        {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"In calloutAccessoryControlTapped");
    
    if (control.tag == 2)//right accessory control "History" tapped
    {
        NSLog(@"right accessory control tapped. control.tag : %li control.title : %@", (long)control.tag, ((UIButton *)control).currentTitle);
        [self performSegueWithIdentifier:@"ShowCityHistory" sender:view];
    }
}


#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *cityName = [citiesToShowOnMap objectAtIndex:currentLocationIndex];
    cityName = [cityName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *weatherRecords = (NSArray *)[[OWCityManager sharedInstance].dictCities objectForKey:cityName];
    return weatherRecords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    UILabel *lblDate = (UILabel *)[cell viewWithTag:1];
    NSString *cityName = [citiesToShowOnMap objectAtIndex:currentLocationIndex];
    cityName = [cityName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"In cellForRowAtIndexPath, cityName : %@", cityName);
    
    OWWeatherRecord *weatherRecord = [[[OWCityManager sharedInstance].dictCities objectForKey:cityName] objectAtIndex:indexPath.row];
    NSLog(@"In cellForRowAtIndexPath, weatherRecord.count : %@", weatherRecord);
    
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
