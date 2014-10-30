//
//  WTCityMainViewController.h
//  Weather
//
//  Created by zzyy on 14-5-25.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTCityMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *cityMainTableView;
@property (retain, nonatomic) IBOutlet UIView *cityMainView;
@property (retain, nonatomic) IBOutlet UIImageView *bgView;
@property (retain, nonatomic) IBOutlet UIView *footView;
@property (retain, nonatomic) IBOutlet UIPageControl *cityDetailInfoScrlPageCtl;
@property (retain, nonatomic) IBOutlet UIScrollView *cityDetailInfoScrl;
//@property (retain, nonatomic) IBOutlet UIScrollView *cityDetailInfoScrl;
@property (retain, nonatomic) IBOutlet UIView *backgroundCityDetailView;
@property (retain, nonatomic) IBOutlet UIView *transparentView;
@property (retain, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureForTransparentView;

@end
