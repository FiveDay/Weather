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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)tapGestureAction:(id)sender {
    
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    //改变它的frame的x,y的值

    self.frame = CGRectMake(self.frame.origin.x, 0, self.frame.size.width,548);
    [UIView commitAnimations];
    [_delegate cellSizeChanged:self];

}

//- (void)drawRect:(CGRect)rect
//{
//    [_delegate cellSizeChanged:self];
//}
- (void)dealloc {
    [_ampm release];
    [_time release];
    [_cityName release];
    [_temperature release];
    [super dealloc];
}
@end
