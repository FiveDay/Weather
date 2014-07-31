//
//  WTCityMainViewController.m
//  Weather
//
//  Created by zzyy on 14-5-25.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import "WTCityMainViewController.h"
#import "WTManager.h"
#import "WTCitySearchViewController.h"
#import "WTCityDetailInfoViewController.h"

@interface WTCityMainViewController ()
{
    UITableViewCell* _cellOfSizeChanged;
    int idx;
    NSIndexPath* _pathOfSizeChanged;
    NSIndexPath* selectedPath;
    BOOL extended;
    CGFloat lastPinchScale;
    IBOutlet UILabel *_cityName;
    IBOutlet UIView *_dataView;
    IBOutlet UIImageView *_imageViewOfCell;
    NSMutableArray* _currentCityDetailInfoViews;
    
    //因为_cityName只表示最后一个创建的tableviewcell上的城市信息，所以，这里需要一个数据
    //能够记录整个tableview上所有的cell的信息。因此，这里的设计最好还是每个cellView都有
    //自己的controller来控制.这里使用cell上的subview设置的tag进行调用。
    BOOL _cellIsAnimating;
}
@end

@implementation WTCityMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _currentCityDetailInfoViews = [[NSMutableArray alloc]initWithCapacity:1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _cityMainTableView.tableFooterView = _footView;
    
    _backgroundCityDetailView.alpha = 0;
    [self.view addSubview:_backgroundCityDetailView];
    
    [[WTManager sharedManager] findCurrentLocation];
    
    [[RACObserve([WTManager sharedManager], currentDataModel)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WTDataModel *newDataModel) {
         if (newDataModel) {
             if([_cityMainTableView numberOfRowsInSection:0])
             {
                 NSIndexPath *path=[NSIndexPath indexPathForRow:0 inSection:0];
                 [_cityMainTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:(UITableViewRowAnimationNone)];
             }else{
                 [_cityMainTableView reloadData];
             }


         }
     }];
    [[RACObserve([WTManager sharedManager], isAddFousData)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(id isAddFousData) {
             [_cityMainTableView reloadData];
     }];

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
    [_footView release];
    [_cityDetailInfoScrl release];
    [_cityDetailInfoScrlPageCtl release];
    [_cityName release];
    [_cityDetailInfoScrl release];
    [_backgroundCityDetailView release];
    [_currentCityDetailInfoViews release];
    [_dataView release];
    [_imageViewOfCell release];
    [super dealloc];
}

#pragma mark UITableViewDataSource

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    int iCityFocusedCount = [[WTManager sharedManager].focusDataModelList count];
    
    if (_cityDetailInfoScrlPageCtl.numberOfPages != iCityFocusedCount) {
        _cityDetailInfoScrl.contentSize = (CGSize){self.view.bounds.size.width*iCityFocusedCount,self.view.bounds.size.height};
        _cityDetailInfoScrlPageCtl.numberOfPages = iCityFocusedCount;
    }
    
    return iCityFocusedCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WTCityInfoCellViewIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WTCityInfoCellView" owner:self options:nil];
        cell = [array objectAtIndex:0];
    }
    
    if(indexPath.row != 0){
        _dataView.frame = CGRectMake(0, _dataView.frame.origin.y-7, _dataView.frame.size.width, _dataView.frame.size.height);
        _imageViewOfCell.image = [UIImage imageNamed:@"afternoon.png"];
    }
    
    if ([[[WTManager sharedManager].focusDataModelList objectAtIndex:indexPath.row] locationName]) {
       //???
//        for (UIView* subview in cell.contentView.subviews) {
//            if (subview.tag == 10001) {
//                ((UILabel*)subview).text = [[[WTManager sharedManager].focusDataModelList objectAtIndex:indexPath.row] locationName];
//                
//            }
//        }
        
       _cityName.text = [[[WTManager sharedManager].focusDataModelList objectAtIndex:indexPath.row] locationName];
    }else{
        _cityName.text = @"--";
    }



    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (_cellOfSizeChanged != nil)
    {
        if (selectedPath.row == indexPath.row)
        {
            return ((_cellIsAnimating && extended) || (!_cellIsAnimating && !extended))?95:548;
        }
    }
    return 95;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [selectedPath release];
    selectedPath = indexPath;
    [selectedPath retain];
    
    _cityDetailInfoScrlPageCtl.currentPage = indexPath.row;
    
    _cellOfSizeChanged = [tableView cellForRowAtIndexPath:indexPath];
    
    
    [self createCityDetailInfoScrlContent];

    
    [self.view bringSubviewToFront:_backgroundCityDetailView];

    [UIView animateWithDuration:0.5 animations:^{
        _cellIsAnimating = YES;
        
        int offset = 88 * (selectedPath.row);
        tableView.contentOffset = (CGPoint){0,offset};
        
        UITableViewCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        selectedCell.frame = (CGRect){selectedCell.frame.origin,CGRectGetWidth(selectedCell.frame),548};
        
        [tableView beginUpdates];
        [tableView endUpdates];
        
        [UIView beginAnimations:@"fff" context:nil];
        [UIView setAnimationDuration:1];
        _backgroundCityDetailView.alpha = 1.0;
        //tableView.alpha = 0.0;
        
        [UIView commitAnimations];
        
        
    }completion:^(BOOL finished){
        _cellIsAnimating = NO;
        extended = YES;
        tableView.scrollEnabled = NO;
        _cityDetailInfoScrl.contentOffset = (CGPoint){(_cityDetailInfoScrlPageCtl.currentPage)*_cityDetailInfoScrl.frame.size.width,0};
    }];

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
    int iCityFocusedCount = [[WTManager sharedManager].focusDataModelList count];
    
    for (int iPage=0; iPage<iCityFocusedCount; iPage++) {
        
        WTCityDetailInfoViewController* wtCityDetailInfoViewController = [[WTCityDetailInfoViewController alloc]initWithNibName:@"WTCityDetailInfoView" bundle:nil];
        
        wtCityDetailInfoViewController.parentViewControllerDelegate = self;
        
        wtCityDetailInfoViewController.view.frame = (CGRect){iPage*CGRectGetWidth(wtCityDetailInfoViewController.view.frame),0,wtCityDetailInfoViewController.view.frame.size};
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:iPage inSection:0];
        UITableViewCell* cellTmp = [_cityMainTableView cellForRowAtIndexPath:indexPath];
        
        for (UIView* subview in cellTmp.contentView.subviews) {
            if (subview.tag == 10001) {
                NSString* cityN = ((UILabel*)subview).text;
                [wtCityDetailInfoViewController loadWTCityDetailInfoViewData:(id)cityN byIndex:iPage];
            }
        }
        
        
        
        [_currentCityDetailInfoViews addObject:wtCityDetailInfoViewController];
        
        [self addChildViewController:wtCityDetailInfoViewController];
        [_backgroundCityDetailView addSubview:wtCityDetailInfoViewController.view];
    }

}

- (void)removeCityDetailInfoScrlContent
{
    for (UIViewController* ctler in self.childViewControllers) {
        [_currentCityDetailInfoViews removeObject:ctler];
        [ctler removeFromParentViewController];
        [ctler.view removeFromSuperview];
    }
}

- (IBAction)pinchHandler:(id)sender
{
    UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)sender;
    
    if (pinch.state == UIGestureRecognizerStateBegan) {
        _cellIsAnimating = YES;
    }
    
    if (pinch.state == UIGestureRecognizerStateChanged) {
        
        //_backgroundCityDetailView.transform = CGAffineTransformMakeScale(1.0, (pinch.scale));
        
        lastPinchScale = pinch.scale;
        
        [self.view bringSubviewToFront:_cityMainTableView];
        
        _cellOfSizeChanged.frame = (CGRect){_cellOfSizeChanged.frame.origin,CGRectGetWidth(_cellOfSizeChanged.frame),548*pinch.scale};
        
        ((WTCityDetailInfoViewController*)_currentCityDetailInfoViews[selectedPath.row]).view.alpha = pinch.scale ;
        
        _cityMainTableView.contentOffset = (CGPoint){0,_cityMainTableView.contentOffset.y*pinch.scale};
        
        _backgroundCityDetailView.alpha = pinch.scale;

        
    }
    
    if (pinch.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 animations:^{
            _backgroundCityDetailView.alpha = 0.0;
            _cityMainTableView.alpha = 1.0;
            _cityDetailInfoScrl.bounds = CGRectMake(0, 0, _cityDetailInfoScrl.frame.size.width, 88);
            [_cityMainTableView beginUpdates];
            [_cityMainTableView endUpdates];
            
            
        } completion:^(BOOL finished){
            _cellIsAnimating = NO;
            extended = NO;
            _cityMainTableView.scrollEnabled = YES;
            _cityDetailInfoScrl.bounds = CGRectMake(0, 0, _cityDetailInfoScrl.frame.size.width, 548);
            lastPinchScale = 1.;
            _backgroundCityDetailView.transform = CGAffineTransformMakeScale(1.0, 1.0);

            [self removeCityDetailInfoScrlContent];
            
            //_cellOfSizeChanged = nil;
            
            
        }];
    }
}

#pragma mark Action
- (IBAction)cfBtnClicked:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    if ((++idx)%2 == 0) {
        //f.png;
        [btn setImage:[UIImage imageNamed:@"f.png"] forState:UIControlStateNormal];
    }else{
        //c.png;
        [btn setImage:[UIImage imageNamed:@"c.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)openSearchView:(id)sender {
    WTCitySearchViewController* controller = [[WTCitySearchViewController alloc]initWithNibName:@"WTCitySearchViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    controller = nil;
}
@end
