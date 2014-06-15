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
    _cityDetailInfoScrl.alpha = 0.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_cityMainTableView release];
    [_cityMainView release];
    [_bgView release];
    [_theLastCell release];
    [_cityDetailInfoScrl release];
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

    _cellOfSizeChanged = [tableView cellForRowAtIndexPath:indexPath];
    
#if 0
    
    [UIView beginAnimations:@"fff" context:nil];
    [UIView setAnimationDuration:0.5];
    int offset = 88 * (selectedPath.row);
    tableView.contentOffset = (CGPoint){0,offset};
    
    [tableView beginUpdates];
    [tableView endUpdates];
    
    [UIView commitAnimations];
    
#else

    [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
        
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

        
        
    }];
    
#endif
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
            return 548;
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
@end
