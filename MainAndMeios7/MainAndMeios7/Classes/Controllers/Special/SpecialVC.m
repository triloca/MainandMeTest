//
//  SpecialVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 11.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SpecialVC.h"
#import "CustomTitleView.h"
#import "SpecialCell.h"
#import "LoadSalesEventsRequest.h"
#import "SearchManager.h"
#import "SalesAndEventsView.h"


@interface SpecialVC ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (weak, nonatomic) IBOutlet UILabel *salesCountLabel;

@property (strong, nonatomic) SalesAndEventsView* salesAndEventsView;
@property (assign, nonatomic) BOOL didLayoutSubviews;

@end

@implementation SpecialVC

#pragma mark - Init



#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak SpecialVC* wSelf = self;
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"SALES & EVENTS" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        [[LayoutManager shared] showHomeControllerAnimated:YES];
        [wSelf.navigationController popToRootViewControllerAnimated:YES];

    }];
    
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    }else{
        
        
        UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
        menuButton.frame = CGRectMake(0, 0, 40, 40);
        [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = anchorLeftButton;
    }

    UINib *cellNib = [UINib nibWithNibName:@"SpecialCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"SpecialCell"];

    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share_btn_grey"]
                                                landscapeImagePhone:nil
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(shareIconClicked:)];
    
    self.navigationItem.rightBarButtonItem = share;
    
    //[self updatePageLabel];

    self.salesAndEventsView = [SalesAndEventsView loadViewFromXIB];
    self.salesAndEventsView.frame = self.view.bounds;
    [self.view addSubview:self.salesAndEventsView];
    
    self.salesAndEventsView.didSelectItem = ^(SalesAndEventsView* sender, NSDictionary* cellInfo, NSArray* collectionArray){
        NSString* link = [cellInfo safeStringObjectForKey:@"link"];
        NSURL* url = [NSURL URLWithString:link];
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    };

    
    if (self.collectionArray && self.selectedIndex != NSNotFound && self.selectedIndex < self.collectionArray.count) {
        self.salesAndEventsView.collectionArray = self.collectionArray;
        [self.salesAndEventsView.collectionView reloadData];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.salesAndEventsView.frame = self.view.bounds;
    
    if (_didLayoutSubviews == NO) {
        _didLayoutSubviews = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.collectionArray && self.selectedIndex != NSNotFound && self.selectedIndex < self.collectionArray.count) {
                [self.salesAndEventsView.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]
                                                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                                       animated:NO];
            }
        });
       
    }
}

- (void)loadData{
    
        if (![ReachabilityManager isReachable]) {
            [[AlertManager shared] showOkAlertWithTitle:@"No Internet connection"];
            return;
        }
        
    
        LoadSalesEventsRequest *productsRequest = [[LoadSalesEventsRequest alloc] init];
        productsRequest.communityId = [SearchManager shared].communityID;
    
    
    if (self.collectionArray.count == 0) {
        [self showSpinnerWithName:@""];
    }
    [[MMServiceProvider sharedProvider] sendRequest:productsRequest success:^(LoadSalesEventsRequest *request) {
            [self hideSpinnerWithName:@""];
            NSLog(@"products: %@", request.events);
            
            self.collectionArray = [NSMutableArray arrayWithArray:request.events];
            [self.collectionView reloadData];
            [self updatePageLabel];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kSetStoreBageValueNotification" object:@(self.collectionArray.count)];
            
        } failure:^(LoadSalesEventsRequest *request, NSError *error) {
            [self hideSpinnerWithName:@""];
            NSLog(@"Error: %@", error);
            
            self.collectionArray = [NSMutableArray new];
            //[_quiltView reloadData];
            [self.collectionView reloadData];
            [[AlertManager shared] showOkAlertWithTitle:@"Error" message:error.localizedDescription];
            [self updatePageLabel];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kSetStoreBageValueNotification" object:@(0)];
        }];
    
}


#pragma mark Page control
- (void)updatePageLabel{
    NSInteger currentPage = (NSInteger)((self.collectionView.contentOffset.x + self.collectionView.frame.size.width / 2)/ self.collectionView.frame.size.width);
    
    NSString* pageString = [NSString stringWithFormat:@"%d of %d", currentPage + 1, self.collectionArray.count];
    self.salesCountLabel.text = pageString;
    
    if (self.collectionArray.count) {
        self.salesCountLabel.hidden = NO;
    }else{
        self.salesCountLabel.hidden = YES;
    }
}
- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //self.navigationController.navigationBarHidden = NO;
   
    if (self.collectionArray.count == 0) {
        [self showSpinnerWithName:@""];
    }
    [self.salesAndEventsView loadDataComletion:^(NSError *error) {
        [self hideSpinnerWithName:@""];
        
    }];

}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //self.navigationController.navigationBarHidden = YES;
}


#pragma mark - Actions

- (void) backAction: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareIconClicked: (id) sender {
    [[AlertManager shared] showOkAlertWithTitle:@"This functinality not implemented yet(in development)"];
}

- (void)settingsPressed{

    //[[ProximityKitManager shared] deleteCompaign:_campaign];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Privat Methods


- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger count = [self.collectionArray count];
    
//    if (count == 0) {
//        _emptyLabel.hidden = NO;
//    }else{
//        _emptyLabel.hidden = YES;
//    }
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SpecialCell";
    
    SpecialCell *cell = (SpecialCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary* cellInfo = self.collectionArray[indexPath.row];
    cell.cellInfo = cellInfo;
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}

//- (void)scrollViewDidEndDecelerating: (UIScrollView *)scrollView {
//    
//    // Calculate where the collection view should be at the right-hand end item
//    float contentOffsetWhenFullyScrolledRight = self.collectionView.frame.size.width * ([self.tableArray count] -1);
//    
//    if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight && !_loading) {
//        self.loading = YES;
//        if (_delegate)
//            [_delegate horisontalListViewdidScrollToEnd:self];
//        [_activityIndicator startAnimating];
//    }
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self updatePageLabel];
}


@end
