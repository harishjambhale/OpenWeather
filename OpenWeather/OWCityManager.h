//
//  OWHistoryManager.h
//  OpenWeather
//
//  Created by Harish Jambhale on 12/01/14.
//  Copyright (c) 2014 Harish Jambhale. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWCityManager : NSObject

@property (nonatomic) NSMutableDictionary* dictCities;

+ (OWCityManager *) sharedInstance;

@end
