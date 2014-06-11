//
//  WTCityMainViewController.h
//  Weather
//
//  Created by zzyy on 14-5-25.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTCityInfoCellView.h"

@interface WTCityMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, WTCityInfoCellDelegate>
@property (retain, nonatomic) IBOutlet UITableView *cityMainTableView;
@property (retain, nonatomic) IBOutlet UIView *cityMainView;
@property (retain, nonatomic) IBOutlet UIImageView *bgView;
@property (retain, nonatomic) IBOutlet UITableViewCell *theLastCell;
@property (retain, nonatomic) IBOutlet UIScrollView *cityDetailInfoScrl;
@end
