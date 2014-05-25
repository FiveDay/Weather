//
//  WTCityInfoCellView.m
//  Weather
//
//  Created by zzyy on 14-5-25.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import "WTCityInfoCellView.h"

@implementation WTCityInfoCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_ampm release];
    [_time release];
    [_cityName release];
    [_temperature release];
    [super dealloc];
}
@end
