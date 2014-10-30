//
//  FDShimmerMaskLayer.m
//  testmove
//
//  Created by zhangnan on 14/10/27.
//  Copyright (c) 2014年 zhangnan. All rights reserved.
//

#import "FDShimmerMaskLayer.h"

@implementation FDShimmerMaskLayer

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        //maskLayer = [CAGradientLayer layer];
        
        UIColor *minColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3];//[UIColor colorWithWhite:1.0 alpha:0.1];
        UIColor *maxColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];//[UIColor colorWithWhite:1.0 alpha:1.0];
        self.colors = @[(__bridge id)minColor.CGColor,(__bridge id)maxColor.CGColor,(__bridge id)minColor.CGColor];
        
        float leftLocation = .4f;
        self.locations = @[@(leftLocation),@0.5,@(1-leftLocation)];
        
        self.startPoint = (CGPoint){0.0,0.0};
        self.endPoint = (CGPoint){1.0,0.0};
    }
    return self;
}

@end
