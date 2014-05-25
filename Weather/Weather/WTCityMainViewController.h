//
//  WTCityMainViewController.h
//  Weather
//
//  Created by zzyy on 14-5-25.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTCityMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) IBOutlet UITableView *cityMainTableView;
@property (retain, nonatomic) IBOutlet UIView *cityMainView;
@end
