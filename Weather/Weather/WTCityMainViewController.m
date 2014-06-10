//
//  WTCityMainViewController.m
//  Weather
//
//  Created by zzyy on 14-5-25.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import "WTCityMainViewController.h"
#import "WTCityInfoCellView.h"

@interface WTCityMainViewController () <UITableViewDataSource, UITableViewDelegate, WTCityInfoCellDelegate>

{
    WTCityInfoCellView* _cellOfSizeChanged;
    int idx;
    NSIndexPath* _pathOfSizeChanged;
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 4) {
        UITableViewCell* cell = _theLastCell;
        return cell;
    }else{
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == 4) {
        return tableView.frame.size.height - 88*4;
    }

    if (_cellOfSizeChanged != nil ) {
        if(indexPath.row == _pathOfSizeChanged.row){
            return _cellOfSizeChanged.frame.size.height;
        }
    }
    return 88;
}

#pragma mark WTCityInfoCellDelegate
- (void)cellSizeChanged:(WTCityInfoCellView*)cell
{
    _cellOfSizeChanged = cell;
    _pathOfSizeChanged = [_cityMainTableView indexPathForCell:_cellOfSizeChanged];
    
    [_cityMainTableView beginUpdates];
    [_cityMainTableView endUpdates];
}
@end
