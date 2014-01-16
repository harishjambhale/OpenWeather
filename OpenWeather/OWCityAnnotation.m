//
//  OWCityAnnotation.m
//  OpenWeather
//
//  Created by Harish Jambhale on 06/01/14.
//  Copyright (c) 2014 Harish Jambhale. All rights reserved.
//

#import "OWCityAnnotation.h"

@implementation OWCityAnnotation

@synthesize title;
@synthesize subtitle;
@synthesize coordinate;

NSString *_cityName;
NSString *_cityDescription;
CLLocationCoordinate2D _coordinate;

- (CLLocationCoordinate2D) coordinate
{
    return _coordinate;
}

-(NSString *)title
{
    return _cityName;
}

-(NSString *)subtitle
{
    return _cityDescription;
}

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description {
    _coordinate = location;
    _cityName = placeName;
    _cityDescription = description;

    return self;
}


@end
