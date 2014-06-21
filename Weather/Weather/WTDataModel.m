//
//  WTDataModel.m
//  Weather
//
//  Created by zzyy on 14/6/15.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import "WTDataModel.h"

//从OpenWeatherMap返回的JSON响应数据：
//{
//    "dt": 1384279857,
//    "id": 5391959,
//    "main": {
//        "humidity": 69,
//        "pressure": 1025,
//        "temp": 62.29,
//        "temp_max": 69.01,
//        "temp_min": 57.2
//    },
//    "name": "San Francisco",
//    "weather": [
//                {
//                    "description": "haze",
//                    "icon": "50d",
//                    "id": 721,
//                    "main": "Haze"
//                } 
//                ] 
//}

//{"coord":{"lon":116.23,"lat":39.54},"sys":{"message":0.0464,"country":"CN","sunrise":1402865227,"sunset":1402919069},"weather":[{"id":801,"main":"Clouds","description":"few clouds","icon":"02d"}],"base":"cmc stations","main":{"temp":85.57,"temp_min":85.57,"temp_max":85.57,"pressure":1010.8,"sea_level":1016.05,"grnd_level":1010.8,"humidity":65},"wind":{"speed":4.26,"deg":174.001},"clouds":{"all":12},"dt":1402882347,"id":1912147,"name":"Yuzhuang","cod":200}

@implementation WTDataModel

- (id)init
{
    if (self = [super init]) {
        NSDate* now = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSInteger flag = NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents *dateComp = [cal components:flag fromDate:now];
        _curHour = [[NSNumber alloc]initWithUnsignedInteger:[dateComp hour]];
        _curMinu = [[NSNumber alloc]initWithUnsignedInteger:[dateComp minute]];
        if (_curHour.intValue >= 12) {
            _isPm = YES;
        }
    }
    return self;
}

- (void)dealloc
{
    [_date release];
    [_temperature release];
    [_locationName release];
    [_curHour release];
    [_curMinu release];
    
    [super dealloc];
}
+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"temperature" : @"main.temp",
             };
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)temperatureJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSNumber numberWithFloat:str.intValue];
    } reverseBlock:^(NSNumber *temperature) {
        return [NSString stringWithFormat:@"%d",[temperature stringValue].intValue];
    }];
}
@end
