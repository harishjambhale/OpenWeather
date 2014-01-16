//
//  OWWeatherRecord.h
//  OpenWeather
//
//  Created by Harish Jambhale on 06/01/14.
//  Copyright (c) 2014 Harish Jambhale. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWWeatherRecord : NSObject
{

}

@property (nonatomic) NSString* strCityName;
@property (nonatomic) NSDate* date;
@property (nonatomic) NSNumber *temp;
@property (nonatomic) NSNumber *pressure;
@property (nonatomic) NSNumber* maxTemp;
@property (nonatomic) NSNumber* minTemp;
@property (nonatomic) NSNumber* humidity;


@end
