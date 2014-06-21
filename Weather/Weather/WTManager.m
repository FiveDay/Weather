//
//  WTManager.m
//  Weather
//
//  Created by zzyy on 14/6/15.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import "WTManager.h"
#import "WTClient.h"
#import "WTDataModel.h"

@interface WTManager ()

// 1
@property (nonatomic, strong, readwrite) WTDataModel *currentDataModel;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;

// 2
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WTClient *client;

@end

@implementation WTManager

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _client = [[WTClient alloc] init];
        
        [[[[RACObserve(self, currentLocation)

            ignore:nil]
           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               return [RACSignal merge:@[
                                         [self updateCurrentConditions],
//                                         [self updateDailyForecast],
//                                         [self updateHourlyForecast]
                                         ]];
           }] deliverOn:RACScheduler.mainThreadScheduler]
         subscribeError:^(NSError *error) {
//             [TSMessage showNotificationWithTitle:@"Error"
//                                         subtitle:@"There was a problem fetching the latest weather."
//                                             type:TSMessageNotificationTypeError];
         }];
    }

    return self;
}

- (RACSignal *)updateCurrentConditions {
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(WTDataModel *dataModel) {
        self.currentDataModel = dataModel;
    }];
}


- (void)findCurrentLocation {
    self.isFirstUpdate = YES;
    CLLocation *location = [[CLLocation alloc]initWithLatitude:39.15 longitude:116.05];
    self.currentLocation = location;
    [self.locationManager startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // 1
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    // 2
    if (location.horizontalAccuracy > 0) {
        // 3
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}
@end
