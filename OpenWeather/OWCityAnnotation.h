//
//  OWCityAnnotation.h
//  OpenWeather
//
//  Created by Harish Jambhale on 06/01/14.
//  Copyright (c) 2014 Harish Jambhale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface OWCityAnnotation : NSObject <MKAnnotation>
{
}

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description;

@end
