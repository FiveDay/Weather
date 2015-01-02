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

static int allDist = 0;

@interface WTCityMainViewController ()<UIGestureRecognizerDelegate>
{
    UITableViewCell* _cellOfSizeChanged;
    int idx;
    NSIndexPath* _pathOfSizeChanged;
    NSIndexPath* selectedPath;
    BOOL extended;
    CGFloat lastPinchScale;
    NSMutableArray* cityNameOnCell;
    NSMutableArray* dataViewOnCell;
    NSMutableArray* imageViewOfCellOnCell;
//    IBOutlet UILabel *_cityName;
//    IBOutlet UIView *_dataView;
//    IBOutlet UIImageView *_imageViewOfCell;
    NSMutableArray* _currentCityDetailInfoViews;
    
    //因为_cityName只表示最后一个创建的tableviewcell上的城市信息，所以，这里需要一个数据
    //能够记录整个tableview上所有的cell的信息。因此，这里的设计最好还是每个cellView都有
    //自己的controller来控制.这里使用cell上的subview设置的tag进行调用。
    BOOL _cellIsAnimating;
    
    //UIPanGestureRecognizer* oldPan;
    CGPoint oldPoint;
    
    UIPinchGestureRecognizer* zhangnanPinch;
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
    //[self.view addSubview:_backgroundCityDetailView];
    
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
         //dispatch_async(dispatch_get_main_queue(), ^{[_cityMainTableView reloadData];});
         [_cityMainTableView reloadData];
     }];
    
    if (!_transparentView.superview) {
        assert(0);
    }else{
        [self.view addSubview:_transparentView.superview];
    }
    
    zhangnanPinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchHandler:)];
    [_cityDetailInfoScrl addGestureRecognizer:zhangnanPinch];

}

- (IBAction)panHandler:(UIPanGestureRecognizer *)sender {
    UIPanGestureRecognizer* curPan = (UIPanGestureRecognizer*)sender;
    
    CGPoint curPoint = [curPan locationInView:_transparentView.superview];
    
    if (oldPoint.x != 0) {
        int deltaX = curPoint.x - oldPoint.x;
        
        NSLog(@"cur:%f   old:%f",curPoint.x,oldPoint.x);
        
        allDist += deltaX;
        allDist = allDist>=0?allDist:0;
        
        float centerTempX = _transparentView.center.x+deltaX;
        
        if (centerTempX < self.view.frame.size.width/2) {
            centerTempX = self.view.frame.size.width/2;
        }
        
        _transparentView.center = (CGPoint){centerTempX,_transparentView.center.y};
        
    }
    
    oldPoint = curPoint;
    
    if (curPan.state == UIGestureRecognizerStateEnded
        || curPan.state == UIGestureRecognizerStateCancelled) {
        
        if (allDist > self.view.frame.size.width/3) {
            
            __block typeof(self) weakSelf = self;
            
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.transparentView.center = (CGPoint){weakSelf.transparentView.center.x+weakSelf.view.frame.size.width/2,weakSelf.transparentView.center.y};
                weakSelf.transparentView.superview.alpha = 0;
                
            } completion:^(BOOL finished){
                weakSelf.transparentView.center = (CGPoint){weakSelf.transparentView.center.x+self.view.frame.size.width/2,weakSelf.transparentView.center.y};
                
                weakSelf.transparentView.superview.alpha = 0;
            }];
            
        }else{
            
            __block typeof(self) weakSelf = self;
            
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.transparentView.center = (CGPoint){weakSelf.view.frame.size.width/2,weakSelf.transparentView.center.y};
            } completion:^(BOOL finished){
                weakSelf.transparentView.center = (CGPoint){self.view.frame.size.width/2,weakSelf.transparentView.center.y};
            }];
            
        }
        
        allDist = 0;
        oldPoint = CGPointZero;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_cityDetailInfoScrl removeGestureRecognizer:zhangnanPinch];
    [zhangnanPinch release];
    zhangnanPinch = nil;
    
    [_cityMainTableView release];
    [_cityMainView release];
    [_bgView release];
    [_footView release];
    [_cityDetailInfoScrl release];
    [_cityDetailInfoScrlPageCtl release];
    [cityNameOnCell release];
    [_backgroundCityDetailView release];
    [_currentCityDetailInfoViews release];
    [dataViewOnCell release];
    [imageViewOfCellOnCell release];
    [_transparentView release];
    [_panGestureForTransparentView release];
    [super dealloc];
}

#pragma mark UITableViewDataSource

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSUInteger iCityFocusedCount = [[WTManager sharedManager].focusDataModelList count];
    
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
        //((UIView*)dataViewOnCell[indexPath.row]).frame = CGRectMake(0, ((UIView*)dataViewOnCell[indexPath.row]).frame.origin.y-7, ((UIView*)dataViewOnCell[indexPath.row]).frame.size.width, ((UIView*)dataViewOnCell[indexPath.row]).frame.size.height);
        //((UIImageView*)imageViewOfCellOnCell[indexPath.row]).image = [UIImage imageNamed:@"afternoon.png"];
        
        ((UIImageView*)[cell viewWithTag:10000]).image = [UIImage imageNamed:@"afternoon.png"];
        
    }
    
    if ([[[WTManager sharedManager].focusDataModelList objectAtIndex:indexPath.row] locationName]) {
       //((UILabel*)cityNameOnCell[indexPath.row]).text
       ((UILabel*)[cell viewWithTag:10001]).text = [[[WTManager sharedManager].focusDataModelList objectAtIndex:indexPath.row] locationName];
        
    }else{
        ((UILabel*)[cell viewWithTag:10001]).text = @"--";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (_cellOfSizeChanged != nil)
    {
        if (selectedPath.row == indexPath.row)
        {
            int cellHeight = _cellOfSizeChanged.frame.size.height;
            return ((_cellIsAnimating && extended) || (!_cellIsAnimating && !extended))?(cellHeight<95?95:cellHeight):568;
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

    UITableViewCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    [selectedCell addSubview:_backgroundCityDetailView];
    [selectedCell.contentView.superview setClipsToBounds:YES];

    [UIView animateWithDuration:0.5 animations:^{
        _cellIsAnimating = YES;
        
        int offset = 88.0 * (selectedPath.row);
        tableView.contentOffset = (CGPoint){0,offset};
        
        UITableViewCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        selectedCell.frame = (CGRect){selectedCell.frame.origin,CGRectGetWidth(selectedCell.frame),568};
        
        [tableView beginUpdates];
        [tableView endUpdates];
        
        [UIView beginAnimations:@"fff" context:nil];
        [UIView setAnimationDuration:1];
        _backgroundCityDetailView.alpha = 1.0;
        //tableView.alpha = 0.0;
        ((UIView*)dataViewOnCell[indexPath.row]).hidden = YES;
        
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
            //没有变化
        }else{
            //滑动产生了焦点索引变化
            _cityDetailInfoScrlPageCtl.currentPage = index;
            
            NSIndexPath* oldSelectedIndexPath = [selectedPath copy];
            
            NSInteger secCount = selectedPath.section;
            [selectedPath release];
            selectedPath = [NSIndexPath indexPathForRow:index inSection:secCount];
            [selectedPath retain];
            
            //according to focuseindex changing,we need to fix the tableview's contentoffset.
            
            UITableViewCell* oldSelectedCell = [_cityMainTableView cellForRowAtIndexPath:oldSelectedIndexPath];
            oldSelectedCell.frame = (CGRect){oldSelectedCell.frame.origin,CGRectGetWidth(oldSelectedCell.frame),95};
            
            _cityMainTableView.contentOffset = (CGPoint){_cityMainTableView.contentOffset.x,95*selectedPath.row};
            
            BOOL animateable = [UIView areAnimationsEnabled];
            [UIView setAnimationsEnabled:NO];
            [_cityMainTableView reloadRowsAtIndexPaths:@[oldSelectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            [UIView setAnimationsEnabled:animateable];
            
            _cellOfSizeChanged = [_cityMainTableView cellForRowAtIndexPath:selectedPath];
            _cellOfSizeChanged.frame = (CGRect){_cellOfSizeChanged.frame.origin,CGRectGetWidth(_cellOfSizeChanged.frame),568};
            
            [oldSelectedIndexPath release];
            
            [_backgroundCityDetailView removeFromSuperview];
            [_cellOfSizeChanged addSubview:_backgroundCityDetailView];
            
            
        }
        
        
        return ;
    }
    
    return ;
}

#pragma mark init ScrollView

- (void)createCityDetailInfoScrlContent
{
    NSInteger iCityFocusedCount = [[WTManager sharedManager].focusDataModelList count];
    
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
        [_cityDetailInfoScrl addSubview:wtCityDetailInfoViewController.view];
        
        [wtCityDetailInfoViewController release];
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
        
        if (568*pinch.scale < 95) {
            return ;
        }
        

        _cellOfSizeChanged.layer.shouldRasterize = YES;
        _backgroundCityDetailView.layer.shouldRasterize = YES;
        _cellOfSizeChanged.layer.rasterizationScale = 1.0 - pinch.scale;
        _backgroundCityDetailView.layer.rasterizationScale = pinch.scale;

        

        BOOL sysAnimateable = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [_cityMainTableView beginUpdates];
        
        [_cityMainTableView endUpdates];
        [UIView setAnimationsEnabled:sysAnimateable];
        
        
        
        ((WTCityDetailInfoViewController*)_currentCityDetailInfoViews[selectedPath.row]).view.alpha = pinch.scale ;
        
        _cellOfSizeChanged.frame = (CGRect){_cellOfSizeChanged.frame.origin,CGRectGetWidth(_cellOfSizeChanged.frame),568*pinch.scale};
        
        _cityMainTableView.contentOffset = (CGPoint){0,_cityMainTableView.contentOffset.y*pinch.scale};
        
        _backgroundCityDetailView.alpha = pinch.scale;

        _cellOfSizeChanged.layer.shouldRasterize = NO;
        _backgroundCityDetailView.layer.shouldRasterize = NO;
        
    }
    
    if (pinch.state == UIGestureRecognizerStateEnded || pinch.state == UIGestureRecognizerStateCancelled) {
        [UIView animateWithDuration:0.5 animations:^{
            _backgroundCityDetailView.alpha = 0.0;
            _cityMainTableView.alpha = 1.0;
            _cityDetailInfoScrl.bounds = CGRectMake(0, 0, _cityDetailInfoScrl.frame.size.width, 88);
            
            if (_cellOfSizeChanged)
            {
                _cellOfSizeChanged.frame = (CGRect){_cellOfSizeChanged.frame.origin,_cellOfSizeChanged.frame.size.width,95};
            }
            
            [_cityMainTableView beginUpdates];
            [_cityMainTableView endUpdates];
            
        } completion:^(BOOL finished){
            _cellIsAnimating = NO;
            extended = NO;
            _cityMainTableView.scrollEnabled = YES;
            _cityDetailInfoScrl.bounds = CGRectMake(0, 0, _cityDetailInfoScrl.frame.size.width, 568);
            lastPinchScale = 1.;
            _backgroundCityDetailView.transform = CGAffineTransformMakeScale(1.0, 1.0);

            _cityMainTableView.contentOffset = (CGPoint){0,0};

            [self removeCityDetailInfoScrlContent];
            
            if (_cellOfSizeChanged)
            {
                _cellOfSizeChanged.frame = (CGRect){_cellOfSizeChanged.frame.origin,_cellOfSizeChanged.frame.size.width,95};
            }
        }];
    }

}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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
