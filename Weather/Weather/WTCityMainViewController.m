//
//  WTCityMainViewController.m
//  Weather
//
//  Created by zzyy on 14-5-25.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import "WTCityMainViewController.h"

#import "WTCityInfoCellView.h"

@interface WTCityMainViewController ()
{
    UITableViewCell* _cellOfSizeChanged;
    int idx;
    NSIndexPath* _pathOfSizeChanged;
    NSIndexPath* selectedPath;
    BOOL extended;
    UIPinchGestureRecognizer* scrollViewPinch;
    CGFloat lastPinchScale;
}
@end

@implementation WTCityMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview:_cityDetailInfoScrl];
    _cityDetailInfoScrl.alpha = 0;
    
    scrollViewPinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchHandler:)];
    [_cityDetailInfoScrl addGestureRecognizer:scrollViewPinch];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pinchHandler:(id)sender
{
    UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)sender;
    
    if (pinch.state == UIGestureRecognizerStateBegan) {
        
    }
    
    if (pinch.state == UIGestureRecognizerStateChanged) {
        
        _cityDetailInfoScrl.transform = CGAffineTransformMakeScale(1.0, (pinch.scale));
        
        
        
        lastPinchScale = pinch.scale;
    }
    
    if (pinch.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 animations:^{
            _cityDetailInfoScrl.alpha = 0.0;
            _cityMainTableView.alpha = 1.0;
            _cityDetailInfoScrl.bounds = CGRectMake(0, 0, _cityDetailInfoScrl.frame.size.width, 88);
            [_cityMainTableView beginUpdates];
            [_cityMainTableView endUpdates];
        } completion:^(BOOL finished){
            extended = NO;
            _cityMainTableView.scrollEnabled = YES;
            _cityDetailInfoScrl.bounds = CGRectMake(0, 0, _cityDetailInfoScrl.frame.size.width, 548);
            lastPinchScale = 1.;
            _cityDetailInfoScrl.transform = CGAffineTransformMakeScale(1.0, 1.0);
            _cityDetailInfoScrlPageCtl.hidden = YES;
        }];
    }
}

- (void)dealloc {
    [_cityMainTableView release];
    [_cityMainView release];
    [_bgView release];
    [_theLastCell release];
    [_cityDetailInfoScrl release];
    [_cityDetailInfoScrlPageCtl release];
    [super dealloc];
}

- (IBAction)cfBtnClicked:(id)sender {
    UIButton* btn = (UIButton*)sender;
    if ((++idx)%2 == 0) {
        //f.png;
        [btn setImage:[UIImage imageNamed:@"f.png"] forState:UIControlStateNormal];
    }else{
        //c.png;
        [btn setImage:[UIImage imageNamed:@"c.png"] forState:UIControlStateNormal];
    }
}

#pragma mark UITableViewDelegate
-(NSInteger) tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    //update _cityDetailInfoScrl contentSize
#if 0
    int iCityFocusedCount = [_cityMainTableView numberOfRowsInSection:0];
    
    if (_cityDetailInfoScrlPageCtl.numberOfPages != iCityFocusedCount) {
        _cityDetailInfoScrl.contentSize = (CGSize){self.view.bounds.size.width*iCityFocusedCount,self.view.bounds.size.height};
        _cityDetailInfoScrlPageCtl.numberOfPages = iCityFocusedCount;
    }
    
    
    _cityDetailInfoScrlPageCtl.currentPage = 0;//selectedPath.row;
#else
    int iCityFocusedCount = 4;
    
    if (_cityDetailInfoScrlPageCtl.numberOfPages != iCityFocusedCount) {
        _cityDetailInfoScrl.contentSize = (CGSize){self.view.bounds.size.width*iCityFocusedCount,self.view.bounds.size.height};
        _cityDetailInfoScrlPageCtl.numberOfPages = iCityFocusedCount;
    }
#endif
    
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if (indexPath.row == 4) {
//        UITableViewCell* cell = _theLastCell;
//        return cell;
//    }else
    {
        static NSString *CellIdentifier = @"WTCityInfoCellViewIdentifier";
        WTCityInfoCellView *cell = (WTCityInfoCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WTCityInfoCellView" owner:self options:nil];
            cell = [array objectAtIndex:0];
            cell.delegate = self;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    int iCellNotReuseMaxCount = (tableView.frame.size.height / 88)+1;
//    if (iCellNotReuseMaxCount < 7) {
//        return
//    }
    return _theLastCell.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _theLastCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [selectedPath release];
    selectedPath = indexPath;
    [selectedPath retain];
    
    _cityDetailInfoScrlPageCtl.hidden = NO;
    _cityDetailInfoScrlPageCtl.currentPage = indexPath.row;
    [self.view bringSubviewToFront:_cityDetailInfoScrlPageCtl];
    
    [self createCityDetailInfoScrlContent];

    _cellOfSizeChanged = [tableView cellForRowAtIndexPath:indexPath];

    [UIView animateWithDuration:0.5 animations:^{
        
        int offset = 88 * (selectedPath.row);
        tableView.contentOffset = (CGPoint){0,offset};
        
        [tableView beginUpdates];
        [tableView endUpdates];
        
        [UIView beginAnimations:@"fff" context:nil];
        [UIView setAnimationDuration:1];
        _cityDetailInfoScrl.alpha = 1.0;
        tableView.alpha = 0.0;
        
        [UIView commitAnimations];
        
    }completion:^(BOOL finished){
        extended = YES;
        tableView.scrollEnabled = NO;
        _cityDetailInfoScrl.contentOffset = (CGPoint){(_cityDetailInfoScrlPageCtl.currentPage)*_cityDetailInfoScrl.frame.size.width,0};
    }];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
//    if (indexPath.row == 4) {
//        return tableView.frame.size.height - 88*4;
//    }

//    if (_cellOfSizeChanged != nil ) {
//        if(indexPath.row == _pathOfSizeChanged.row){
//            return 548;//_cellOfSizeChanged.frame.size.height;
//        }
//    }
    
    if (_cellOfSizeChanged != nil)
    {
        if (selectedPath.row == indexPath.row)
        {
            return extended?88:548;
        }
    }
    return 88;
}

#pragma mark WTCityInfoCellDelegate
- (void)cellSizeChanged:(UITableViewCell*)cell
{
    _cellOfSizeChanged = cell;
    _pathOfSizeChanged = [_cityMainTableView indexPathForCell:_cellOfSizeChanged];
    [_cityMainTableView reloadData];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_cityDetailInfoScrl]) {
         
        int index = fabs(scrollView.contentOffset.x) /scrollView.frame.size.width;
        
        if ((index) == _cityDetailInfoScrlPageCtl.currentPage)
        {
            
        }else{
            _cityDetailInfoScrlPageCtl.currentPage = index;
            
            int secCount = selectedPath.section;
            [selectedPath release];
            selectedPath = [NSIndexPath indexPathForRow:index inSection:secCount];
            [selectedPath retain];
            
        }
        
        
        return ;
    }
    
    return ;
}

#pragma mark init ScrollView
- (void)createCityDetailInfoScrlContent
{
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 100, 40)];
    [lab setText:@"sadfasd"];
    
    [_cityDetailInfoScrl addSubview:lab];
}
@end
