//
//  WTCityMainViewController.h
//  Weather
//
//  Created by zzyy on 14-5-25.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTCityMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

//mainView
@property (retain, nonatomic) IBOutlet UIView *cityMainView;
@property (retain, nonatomic) IBOutlet UITableView *cityMainTableView;
@property (retain, nonatomic) IBOutlet UIView *dataViewOfCell;
@property (retain, nonatomic) IBOutlet UIImageView *bgView;
@property (retain, nonatomic) IBOutlet UIView *footView;


//scrollView
@property (retain, nonatomic) IBOutlet UIView *scrollMainView;
@property (retain, nonatomic) IBOutlet UIScrollView *cityDetailInfoScrl;
@property (retain, nonatomic) IBOutlet UIPageControl *cityDetailInfoScrlPageCtl;

//lockView
@property (retain, nonatomic) IBOutlet UIView *transparentView;
@property (retain, nonatomic) IBOutlet UIView *lockView;

@end
