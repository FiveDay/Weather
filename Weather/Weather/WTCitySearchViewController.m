//
//  WTCitySearchViewController.m
//  Weather
//
//  Created by zzyy on 14/6/22.
//  Copyright (c) 2014年 zzyy. All rights reserved.
//

#import "WTCitySearchViewController.h"
#import "WTManager.h"

@interface WTCitySearchViewController ()
@property (retain, nonatomic) IBOutlet UITableView * searchResults;
@property (retain, nonatomic) IBOutlet UILabel *cityName;

@end

@implementation WTCitySearchViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    // Do any additional setup after loading the view.
    
    [[RACObserve([WTManager sharedManager], isSearchResult)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WTDataModel *newDataModel) {
         if (newDataModel) {
             [_searchResults reloadData];
         }
     }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_searchResults release];
    [_cityName release];
    [super dealloc];
}
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length != 0) {
        [WTManager sharedManager].searchKey = searchBar.text;
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[WTManager sharedManager].searchDataModeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WTSearchCellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WTSearchCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
    }
    
    if ([[[WTManager sharedManager].searchDataModeList objectAtIndex:indexPath.row] locationName]) {
        _cityName.text = [[[WTManager sharedManager].searchDataModeList objectAtIndex:indexPath.row] locationName];
    }else{
        _cityName.text = @"--";
    }
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[WTManager sharedManager].focusDataModelList
     addObject:[[WTManager sharedManager].searchDataModeList
                objectAtIndex:indexPath.row]];
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [rootPath stringByAppendingPathComponent:@"focusDataModelList.dat"];
    NSData  *data = [NSKeyedArchiver archivedDataWithRootObject:[WTManager sharedManager].focusDataModelList];
    [data writeToFile:path atomically:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
    [WTManager sharedManager].isAddFousData = YES;
}

@end
