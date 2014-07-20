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

@property (nonatomic, assign, readwrite) BOOL isSearchResult;

@property (nonatomic, strong, readwrite) WTDataModel *currentDataModel;
@property (nonatomic, strong, readwrite) NSMutableArray *focusDataModelList;
@property (nonatomic, strong, readwrite) NSMutableArray* searchDataModeList;

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
        _searchDataModeList = [[NSMutableArray alloc] init];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        _client = [[WTClient alloc] init];
        
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [rootPath stringByAppendingPathComponent:@"focusDataModelList.dat"];
        NSData *data = [NSData dataWithContentsOfFile:path];//读取文件
        if (data) {
            self.focusDataModelList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }else{
            _focusDataModelList = [[NSMutableArray alloc] init];
        }
        
        [[[[RACObserve(self, currentLocation)

            ignore:nil]
           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               

            return [RACSignal merge:@[
                                        [self updateCurrentConditions],
                                    ]];

           }] deliverOn:RACScheduler.mainThreadScheduler]
         subscribeError:^(NSError *error) {

         }];
        
        [[[[RACObserve(self, searchKey)
            
            ignore:nil]
           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(NSString *searchKey) {
               
               if([searchKey compare:@""] == NSOrderedSame){
                   return [RACSignal empty];
               }else{
                   return [RACSignal merge:@[
                                             [self searchByCityName:searchKey],
                                             ]];
               }

           }] deliverOn:RACScheduler.mainThreadScheduler]
         subscribeError:^(NSError *error) {
             
         }];
    }

    return self;
}
#pragma mark Internal function
- (RACSignal *)updateCurrentConditions
{
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(WTDataModel* dataModel) {
        if([self.focusDataModelList count] > 0){
            [self.focusDataModelList replaceObjectAtIndex:0 withObject:dataModel];
        }else{
            [self.focusDataModelList addObject:dataModel];
        }
        self.currentDataModel = dataModel;
        
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [rootPath stringByAppendingPathComponent:@"currentDataModelFile.dat"];
        NSData  *data = [NSKeyedArchiver archivedDataWithRootObject:self.focusDataModelList];
        [data writeToFile:path atomically:YES];
    }];
}
- (RACSignal*)searchByCityName:(NSString*)cityName
{
    return [[self.client fetchCityDataByCityName:cityName] doNext:^(WTDataModel* dataModel) {
        [self.searchDataModeList addObject:dataModel];

        self.isSearchResult = YES;
    }];
}

#pragma mark Interface function
- (void)findCurrentLocation
{
    self.isFirstUpdate = YES;
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:39.15 longitude:116.05];
    self.currentLocation = location;
    //tmp delete
    //[self.locationManager startUpdatingLocation];
    //end
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
