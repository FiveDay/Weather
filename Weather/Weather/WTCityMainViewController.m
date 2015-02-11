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
#import "WeatherGlobalValue.h"

@interface WTCityMainViewController ()
{
    UITableViewCell* _cellOfSizeChanged;
    int idx;
    NSIndexPath* _pathOfSizeChanged;
    CGFloat lastPinchScale;
    NSMutableArray* _currentCityDetailInfoViews;
    
    BOOL _cellIsAnimating;
    
    NSIndexPath* _selectedCellPath;

}
@property(nonatomic, strong) NSIndexPath* selectedCellPath;
@property(nonatomic, assign) BOOL extended;
@end

@implementation WTCityMainViewController

@synthesize selectedCellPath;

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
    
    [self showLockView];
    
    _extended = false;
    
    _cityMainTableView.tableFooterView = _footView;
    
    _scrollMainView.alpha = 0;
    
   // [[WTManager sharedManager] findCurrentLocation];
    
    //observe currentDataModel
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
 
}

- (void)viewWillAppear:(BOOL)animated
{
    [_cityMainTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    //mainView
    [_cityMainView release];
    [_cityMainTableView release];
    [_dataViewOfCell release];
    [_bgView release];
    [_footView release];
    
    //scrollMainView
    [_scrollMainView release];
    [_cityDetailInfoScrl release];
    [_cityDetailInfoScrlPageCtl release];
    [_currentCityDetailInfoViews release];
    
    //lockView
    [_transparentView release];
    [_lockView release];
    

    [super dealloc];
}

#pragma mark LockView

- (void)showLockView
{
    [_cityMainView addSubview:_lockView];
}

- (void)unShowLockView
{
    [_lockView removeFromSuperview];
}

- (IBAction)panHandlerForLockView:(UIPanGestureRecognizer *)sender {
    UIPanGestureRecognizer* curPan = (UIPanGestureRecognizer*)sender;
    
    CGPoint translation = [sender translationInView:self.view];
    CGPoint center = self.lockView.center;
    _transparentView.center = (CGPoint){center.x + translation.x ,_transparentView.center.y};
   
    if (curPan.state == UIGestureRecognizerStateEnded
        || curPan.state == UIGestureRecognizerStateCancelled) {
        
        if (translation.x > self.view.frame.size.width/3) {
            
            __block typeof(self) weakSelf = self;
            
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.transparentView.center =
                (CGPoint){center.x + weakSelf.lockView.frame.size.width/2, weakSelf.transparentView.center.y};
                
            } completion:^(BOOL finished){
                weakSelf.transparentView.center =
                (CGPoint){center.x+weakSelf.lockView.frame.size.width/2, weakSelf.transparentView.center.y};
                
                [weakSelf unShowLockView];
            }];
            
        }else{
            
            __block typeof(self) weakSelf = self;
            
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.transparentView.center = (CGPoint){center.x, weakSelf.transparentView.center.y};
            } completion:^(BOOL finished){
                weakSelf.transparentView.center = (CGPoint){center.x, weakSelf.transparentView.center.y};
            }];
            
        }
    }
}

#pragma mark UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSUInteger iCityFocusedCount = [[WTManager sharedManager].focusDataModelList count];
    
//    if (_cityDetailInfoScrlPageCtl.numberOfPages != iCityFocusedCount) {
//        _cityDetailInfoScrl.contentSize = (CGSize){self.view.bounds.size.width*iCityFocusedCount,_cityDetailInfoScrl.bounds.size.height};
//        _cityDetailInfoScrlPageCtl.numberOfPages = iCityFocusedCount;
//    }
    
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
    
    //data bind
    if ([[[WTManager sharedManager].focusDataModelList objectAtIndex:indexPath.row] locationName]) {
       ((UILabel*)[cell viewWithTag:10001]).text = [[[WTManager sharedManager].focusDataModelList objectAtIndex:indexPath.row] locationName];
        
    }else{
        ((UILabel*)[cell viewWithTag:10001]).text = @"--";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
//    if (_cellOfSizeChanged != nil)
//    {
        if (_extended && self.selectedCellPath.row == indexPath.row)
        {
//            int cellHeight = _cellOfSizeChanged.frame.size.height;
//            return ((_cellIsAnimating && extended)
//                    || (!_cellIsAnimating && !extended))?(cellHeight<95?95:cellHeight):568;
            return SCREEN_HEIGHT;
        }
//    }
    
    if (indexPath.row != 0) {

        return 80;
    }
    return 96;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCellPath = indexPath;
    if (_extended) {
        _extended = false;
    }else{
        _extended = true;
    }
//    
//    _cityDetailInfoScrlPageCtl.currentPage = indexPath.row;
//    
//    _cellOfSizeChanged = [tableView cellForRowAtIndexPath:indexPath];
//    
//    
//    [self createCityDetailInfoScrlContent];
//
//      UITableViewCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    [selectedCell addSubview:_scrollMainView];
//    [selectedCell.contentView.superview setClipsToBounds:YES];
//
    [tableView beginUpdates];
    [tableView endUpdates];
    
    [UIView animateWithDuration:0.5 animations:^{

        

       // _cellIsAnimating = YES;
        
        int offset = 96.0 * (indexPath.row);
        tableView.contentOffset = (CGPoint){0,offset};
//
//        selectedCell.frame = (CGRect){selectedCell.frame.origin,CGRectGetWidth(selectedCell.frame),SCREEN_HEIGHT};
        

        
//        [UIView beginAnimations:@"fff" context:nil];
//        [UIView setAnimationDuration:1];
//        _scrollMainView.alpha = 1.0;
//        //tableView.alpha = 0.0;
//
//        [selectedCell viewWithTag:10009].hidden = YES;
//        
//        [UIView commitAnimations];
//        
        
    }completion:^(BOOL finished){
//        _cellIsAnimating = NO;
//        extended = YES;
//        tableView.scrollEnabled = NO;
//        _cityDetailInfoScrl.contentOffset = (CGPoint){(_cityDetailInfoScrlPageCtl.currentPage)*_cityDetailInfoScrl.frame.size.width,0};
    }
     ];

}


//
//#pragma mark UIScrollViewDelegate
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if ([scrollView isEqual:_cityDetailInfoScrl]) {
//         
//        int index = fabs(scrollView.contentOffset.x) /scrollView.frame.size.width;
//        
//        if ((index) == _cityDetailInfoScrlPageCtl.currentPage)
//        {
//            //没有变化
//        }else{
//            //滑动产生了焦点索引变化
//            _cityDetailInfoScrlPageCtl.currentPage = index;
//            
//            NSIndexPath* oldSelectedIndexPath = [selectedPath copy];
//            
//            NSInteger secCount = selectedPath.section;
//            [selectedPath release];
//            selectedPath = [NSIndexPath indexPathForRow:index inSection:secCount];
//            [selectedPath retain];
//            
//            //according to focuseindex changing,we need to fix the tableview's contentoffset.
//            
//            UITableViewCell* oldSelectedCell = [_cityMainTableView cellForRowAtIndexPath:oldSelectedIndexPath];
//            oldSelectedCell.frame = (CGRect){oldSelectedCell.frame.origin,CGRectGetWidth(oldSelectedCell.frame),95};
//            
//            _cityMainTableView.contentOffset = (CGPoint){_cityMainTableView.contentOffset.x,95*selectedPath.row};
//            
//            BOOL animateable = [UIView areAnimationsEnabled];
//            [UIView setAnimationsEnabled:NO];
//            [_cityMainTableView reloadRowsAtIndexPaths:@[oldSelectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//            
//            [UIView setAnimationsEnabled:animateable];
//            
//            _cellOfSizeChanged = [_cityMainTableView cellForRowAtIndexPath:selectedPath];
//            _cellOfSizeChanged.frame = (CGRect){_cellOfSizeChanged.frame.origin,CGRectGetWidth(_cellOfSizeChanged.frame),568};
//            
//            [oldSelectedIndexPath release];
//            
//            //?????怎么处理这里？
//            [_cellOfSizeChanged addSubview:_scrollMainView];
//            
//            
//        }
//        
//        
//        return ;
//    }
//    
//    return ;
//}
//
//#pragma mark ScrollView
//
//- (void)createCityDetailInfoScrlContent
//{
//    NSInteger iCityFocusedCount = [[WTManager sharedManager].focusDataModelList count];
//    
//    for (int iPage=0; iPage<iCityFocusedCount; iPage++) {
//        
//        WTCityDetailInfoViewController* wtCityDetailInfoViewController = [[WTCityDetailInfoViewController alloc]initWithNibName:@"WTCityDetailInfoView" bundle:nil];
//        
//        wtCityDetailInfoViewController.parentViewControllerDelegate = self;
//        
//        wtCityDetailInfoViewController.view.frame = (CGRect){iPage*CGRectGetWidth(wtCityDetailInfoViewController.view.frame),0,wtCityDetailInfoViewController.view.frame.size};
//        
//        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:iPage inSection:0];
//        UITableViewCell* cellTmp = [_cityMainTableView cellForRowAtIndexPath:indexPath];
//        
//        for (UIView* subview in cellTmp.contentView.subviews) {
//            if (subview.tag == 10001) {
//                NSString* cityN = ((UILabel*)subview).text;
//                [wtCityDetailInfoViewController loadWTCityDetailInfoViewData:(id)cityN byIndex:iPage];
//            }
//        }
//        
//        
//        
//        [_currentCityDetailInfoViews addObject:wtCityDetailInfoViewController];
//        
//        [self addChildViewController:wtCityDetailInfoViewController];
//        [_cityDetailInfoScrl addSubview:wtCityDetailInfoViewController.view];
//
//        [wtCityDetailInfoViewController release];
//    }
//
//}
//
//- (void)removeCityDetailInfoScrlContent
//{
//    for (UIViewController* ctler in self.childViewControllers) {
//        [_currentCityDetailInfoViews removeObject:ctler];
//        [ctler removeFromParentViewController];
//        [ctler.view removeFromSuperview];
//    }
//}
//
//- (IBAction)pinchHandlerForScrollView:(id)sender
//{
//    UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)sender;
//    
//    if (pinch.state == UIGestureRecognizerStateBegan) {
//        _cellIsAnimating = YES;
//    }
//    
//    if (pinch.state == UIGestureRecognizerStateChanged) {
//        
//        
//        lastPinchScale = pinch.scale;
//        
//        [self.view bringSubviewToFront:_cityMainTableView];
//        
//        if (568*pinch.scale < 95) {
//            return ;
//        }
//        
//
//        _cellOfSizeChanged.layer.shouldRasterize = YES;
//        _cityDetailInfoScrl.layer.shouldRasterize = YES;
//        _cellOfSizeChanged.layer.rasterizationScale = 1.0 - pinch.scale;
//        _cityDetailInfoScrl.layer.rasterizationScale = pinch.scale;
//
//        
//
//        BOOL sysAnimateable = [UIView areAnimationsEnabled];
//        [UIView setAnimationsEnabled:NO];
//        [_cityMainTableView beginUpdates];
//        
//        [_cityMainTableView endUpdates];
//        [UIView setAnimationsEnabled:sysAnimateable];
//        
//        
//        
//        ((WTCityDetailInfoViewController*)_currentCityDetailInfoViews[selectedPath.row]).view.alpha = pinch.scale ;
//        
//        _cellOfSizeChanged.frame = (CGRect){_cellOfSizeChanged.frame.origin,CGRectGetWidth(_cellOfSizeChanged.frame),568*pinch.scale};
//        
//        _cityMainTableView.contentOffset = (CGPoint){0,_cityMainTableView.contentOffset.y*pinch.scale};
//        
//        _scrollMainView.alpha = pinch.scale;
//        
//        [_cellOfSizeChanged viewWithTag:10009].hidden = NO;
//        
//        [_cellOfSizeChanged viewWithTag:10009].alpha = 1.0-pinch.scale;
//
//        _cellOfSizeChanged.layer.shouldRasterize = NO;
//        _scrollMainView.layer.shouldRasterize = NO;
//        
//    }
//    
//    if (pinch.state == UIGestureRecognizerStateEnded || pinch.state == UIGestureRecognizerStateCancelled) {
//        [UIView animateWithDuration:0.5 animations:^{
//            _scrollMainView.alpha = 0.0;
//            _cityMainTableView.alpha = 1.0;
//            _scrollMainView.bounds = CGRectMake(0, 0, _scrollMainView.frame.size.width, 95);
//            
//            if ([_cellOfSizeChanged viewWithTag:10009].alpha < 1.0f) {
//                [_cellOfSizeChanged viewWithTag:10009].alpha = 1.0f;
//            }
//            
//            if (_cellOfSizeChanged)
//            {
//                _cellOfSizeChanged.frame = (CGRect){_cellOfSizeChanged.frame.origin,_cellOfSizeChanged.frame.size.width,95};
//            }
//            
//            [_cityMainTableView beginUpdates];
//            [_cityMainTableView endUpdates];
//            
//        } completion:^(BOOL finished){
//            _cellIsAnimating = NO;
//            extended = NO;
//            _cityMainTableView.scrollEnabled = YES;
//            _scrollMainView.bounds = CGRectMake(0, 0, _scrollMainView.frame.size.width, 504);
//            lastPinchScale = 1.;
//            _scrollMainView.transform = CGAffineTransformMakeScale(1.0, 1.0);
//
//            _cityMainTableView.contentOffset = (CGPoint){0,0};
//
//            [self removeCityDetailInfoScrlContent];
//            
//            if (_cellOfSizeChanged)
//            {
//                _cellOfSizeChanged.frame = (CGRect){_cellOfSizeChanged.frame.origin,_cellOfSizeChanged.frame.size.width,95};
//                
//                [_cellOfSizeChanged viewWithTag:10009].alpha = 1.0f;
//            }
//        }];
//    }
//
//}

#pragma mark Button action in foot view

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
