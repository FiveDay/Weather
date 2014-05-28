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
    NSIndexPath* cellNumberInPinching;
    int cellNumberInPinchingHeight;
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
    [super dealloc];
}

#pragma mark MemberFunctions
- (void)saveCellNumberInPinching:(WTCityInfoCellView*)cell
{
    cellNumberInPinching = [self.cityMainTableView indexPathForCell:cell];
    cellNumberInPinchingHeight = cell.frame.size.height;
}

#pragma mark UITableViewDelegate
-(NSInteger) tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 9) {
        UITableViewCell* cell = _theLastCell;
        return cell;
    }else{
        static NSString *CellIdentifier = @"WTCityInfoCellViewIdentifier";
        WTCityInfoCellView *cell = (WTCityInfoCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WTCityInfoCellView" owner:self options:nil];
            cell = [array objectAtIndex:0];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == cellNumberInPinching.row && indexPath.section == cellNumberInPinching.section) {
        //pinching cell.
        return cellNumberInPinchingHeight;
    }
    
    return 88;
}
@end
