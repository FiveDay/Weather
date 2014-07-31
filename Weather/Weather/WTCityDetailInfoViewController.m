//
//  WTCityDetailInfoViewController.m
//  Weather
//
//  Created by zhangnan on 14/7/18.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import "WTCityDetailInfoViewController.h"
#import "WTSingleTimeViewController.h"

#define SINGLE_LABEL_WIDTH 50

@interface WTCityDetailInfoViewController ()

@end

@implementation WTCityDetailInfoViewController
@synthesize parentViewControllerDelegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    int leftMargin = 15;
    int rightMargin =15;
    
    _detailTimeScrollView.contentSize = (CGSize){SINGLE_LABEL_WIDTH*14+leftMargin+rightMargin,_detailTimeScrollView.frame.size.height};
    
    for (int i=0; i<14; i++) {
        WTSingleTimeViewController *singleTimeViewCtler = [[WTSingleTimeViewController alloc]initWithNibName:@"WTSingleTimeViewController" bundle:nil];
        
        singleTimeViewCtler.view.frame = (CGRect){leftMargin+i*SINGLE_LABEL_WIDTH,0,singleTimeViewCtler.view.frame.size};
        
        [_detailTimeScrollView addSubview:singleTimeViewCtler.view];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadWTCityDetailInfoViewData:(id)info byIndex:(NSInteger)citySelectedIndex
{
    NSString* citynametmp = info;
    
    _cityNameOfWTCityDetailInfo.text = citynametmp;
}

- (IBAction)pinchHandleInDetailInfoView:(id)sender {
    if (self.parentViewControllerDelegate) {
        [self.parentViewControllerDelegate performSelector:@selector(pinchHandler:) withObject:sender];
    }
}

- (void)dealloc
{
    [_cityNameOfWTCityDetailInfo release];
    [_detailTimeScrollView release];
    [super dealloc];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
