//
//  WTCityInfoCellView.h
//  Weather
//
//  Created by zzyy on 14-5-25.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTCityInfoCellView : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *ampm;
@property (retain, nonatomic) IBOutlet UILabel *time;
@property (retain, nonatomic) IBOutlet UILabel *cityName;
@property (retain, nonatomic) IBOutlet UILabel *temperature;
@end
