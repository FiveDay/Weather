//
//  FDShimmerLabel.m
//  testmove
//
//  Created by zhangnan on 14/10/27.
//  Copyright (c) 2014年 zhangnan. All rights reserved.
//

#import "FDShimmerLabel.h"
#import "FDShimmerMaskLayer.h"

static NSString* kcSlideAnimation = @"slide";

@interface FDShimmerLabel ()
{
    FDShimmerMaskLayer* maskLayer;
}
@end

@implementation FDShimmerLabel

- (void)awakeFromNib
{
    // Initialization code
    maskLayer = [[FDShimmerMaskLayer alloc]init];
    float maskLayerWidth = 3.0f * CGRectGetWidth(self.frame);
    maskLayer.position = (CGPoint){-CGRectGetWidth(self.frame)/2,CGRectGetHeight(self.frame)/2};
    maskLayer.bounds = CGRectMake(0.0, 0.0, maskLayerWidth, CGRectGetHeight(self.frame));
    
    //maskLayer.backgroundColor = [UIColor redColor].CGColor;
    
    self.layer.mask = maskLayer;
    
    CAAnimation* slideAnimation = [maskLayer animationForKey:kcSlideAnimation];
    CFTimeInterval slideDuration = 0.8f;
    
    if (slideAnimation) {
        //go back animation
    } else {
        //nil
        slideAnimation = [self createFDShimmerSlideAnimation:self duration:slideDuration];
        
        [maskLayer addAnimation:slideAnimation forKey:kcSlideAnimation];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        maskLayer = [[FDShimmerMaskLayer alloc]init];
        float maskLayerWidth = 3.0f * CGRectGetWidth(self.frame);
        maskLayer.position = (CGPoint){-CGRectGetWidth(self.frame)/2,CGRectGetHeight(self.frame)/2};
        maskLayer.bounds = CGRectMake(0.0, 0.0, maskLayerWidth, CGRectGetHeight(self.frame));
        
        //maskLayer.backgroundColor = [UIColor redColor].CGColor;
        
        self.layer.mask = maskLayer;
        
        CAAnimation* slideAnimation = [maskLayer animationForKey:kcSlideAnimation];
        CFTimeInterval slideDuration = 1.5f;
        
        if (slideAnimation) {
            //go back animation
        } else {
            //nil
            slideAnimation = [self createFDShimmerSlideAnimation:self duration:slideDuration];
            
            [maskLayer addAnimation:slideAnimation forKey:kcSlideAnimation];
        }

        
    
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (CAAnimation*)createFDShimmerSlideAnimation:(id)animationDelegate duration:(CFTimeInterval)duration
{
    FDShimmerLabel* labelDelegate = (FDShimmerLabel*)animationDelegate;
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.delegate = animationDelegate;
    animation.duration = duration;
    animation.repeatCount = HUGE_VALF;
    
    animation.toValue = [NSValue valueWithCGPoint:(CGPoint){3.0f*CGRectGetWidth(labelDelegate.frame)/2,CGRectGetHeight(labelDelegate.frame)/2}];
    return animation;
}


@end
