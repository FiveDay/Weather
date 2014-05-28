//
//  WTCityInfoCellView.m
//  Weather
//
//  Created by zzyy on 14-5-25.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import "WTCityInfoCellView.h"
#import "WTCityMainViewController.h"

@interface WTCityInfoCellView ()
{
    float currentScale;
}
@end
@implementation WTCityInfoCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    if (self=[super init]) {
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)pinchHandler:(id)sender {
    WTCityMainViewController* mainCtller = self.cellOwner;
    
    UIPinchGestureRecognizer* pinchRecg = (UIPinchGestureRecognizer*)sender;
    
    if (pinchRecg.state == UIGestureRecognizerStateBegan
        && currentScale!=0.0) {
        pinchRecg.scale = currentScale;
    } else if (pinchRecg.state == UIGestureRecognizerStateEnded && pinchRecg.scale<=1.0){
        currentScale = 1.0;
        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        
        
        [mainCtller saveCellNumberInPinching:self];
        
        [mainCtller.cityMainTableView reloadData];
    }
    
    if (pinchRecg.scale != NAN && /*pinchRecg.scale != 0.0 &&*/ pinchRecg.scale >= 0.9) {
        
        
        self.transform = CGAffineTransformMakeScale(1.0, pinchRecg.scale);
        
        
        [mainCtller saveCellNumberInPinching:self];
        
        [mainCtller.cityMainTableView reloadData];
    }
}

- (void)dealloc {
    [_ampm release];
    [_time release];
    [_cityName release];
    [_temperature release];
    [_cellPinchGesture release];
    [_cellOwner release];
    [super dealloc];
}
@end
