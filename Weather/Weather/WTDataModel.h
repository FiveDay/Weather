//
//  WTDataModel.h
//  Weather
//
//  Created by zzyy on 14/6/15.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@interface WTDataModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSDate*   date;
@property (nonatomic, strong) NSNumber* temperature;
@property (nonatomic, strong) NSString* locationName;

@property (nonatomic, strong) NSNumber* curHour;
@property (nonatomic, strong) NSNumber* curMinu;
@property (nonatomic, assign) BOOL      isPm;
@end
