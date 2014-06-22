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

@property (nonatomic, strong, readwrite) CLLocation *currentLocation;

@property (nonatomic, strong, readwrite) WTDataModel *currentDataModel;
@property (nonatomic, strong, readwrite) NSMutableArray *focusDataModelList;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WTClient *client;

@end

@implementation WTManager

+ (instancetype)sharedManager
{
    
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init
{
    if (self = [super init]) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _client = [[WTClient alloc] init];
        
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [rootPath stringByAppendingPathComponent:@"currentDataModelFile.dat"];
        NSData *data = [NSData dataWithContentsOfFile:path];//读取文件
        if (data) {
            self.currentDataModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];;
        }
        
        [[[[RACObserve(self, currentLocation)

            ignore:nil]
           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               
               if (newLocation.coordinate.latitude != self.currentLocation.coordinate.latitude
                   ||newLocation.coordinate.longitude != self.currentLocation.coordinate.longitude) {
                   return [RACSignal merge:@[
                                             [self updateCurrentConditions],
                                             ]];
               }
               return [RACSignal empty];
           }] deliverOn:RACScheduler.mainThreadScheduler]
         subscribeError:^(NSError *error) {
//             [TSMessage showNotificationWithTitle:@"Error"
//                                         subtitle:@"There was a problem fetching the latest weather."
//                                             type:TSMessageNotificationTypeError];
         }];
    }

    return self;
}

- (RACSignal *)updateCurrentConditions
{
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(WTDataModel *dataModel) {
        self.currentDataModel = dataModel;
        
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [rootPath stringByAppendingPathComponent:@"currentDataModelFile.dat"];
        NSData  *data = [NSKeyedArchiver archivedDataWithRootObject:dataModel];
        [data writeToFile:path atomically:YES];
    }];
}


- (void)findCurrentLocation
{
    self.isFirstUpdate = YES;
    CLLocation *location = [[CLLocation alloc]initWithLatitude:39.15 longitude:116.05];
    self.currentLocation = location;
    [self.locationManager startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    if (location.horizontalAccuracy > 0) {
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}
@end
