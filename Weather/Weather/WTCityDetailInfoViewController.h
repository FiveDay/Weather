//
//  WTCityDetailInfoViewController.h
//  Weather
//
//  Created by zhangnan on 14/7/18.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTCityDetailInfoViewController : UIViewController
//WTCityDetailInfoView use
@property (retain, nonatomic) IBOutlet UIScrollView *detailTimeScrollView;
@property (retain, nonatomic) IBOutlet UILabel *cityNameOfWTCityDetailInfo;

@property (retain, nonatomic) UIViewController* parentViewControllerDelegate;
- (void)loadWTCityDetailInfoViewData:(id)info byIndex:(NSInteger)citySelectedIndex;
@end
