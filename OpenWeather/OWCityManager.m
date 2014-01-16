//
//  OWHistoryManager.m
//  OpenWeather
//
//  Created by Harish Jambhale on 12/01/14.
//  Copyright (c) 2014 Harish Jambhale. All rights reserved.
//

#import "OWCityManager.h"

@implementation OWCityManager
static OWCityManager *_shareInstance;

+ (OWCityManager *) sharedInstance
{
    @synchronized(_shareInstance)
    {
        if (!_shareInstance) {
            NSLog(@"OWHistoryManager initing");
            _shareInstance = [[OWCityManager alloc] init];
            _shareInstance.dictCities = [[NSMutableDictionary alloc] init];
        }
    }
    
    return _shareInstance;
}

@end
