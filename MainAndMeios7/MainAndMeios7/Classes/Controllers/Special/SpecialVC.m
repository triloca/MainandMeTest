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

@interface SpecialVC ()
@property (strong, nonatomic) NSArray* tableArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;

@end

@implementation SpecialVC

#pragma mark - Init



#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"SPECIALS & EVENTS" dropDownIndicator:NO clickCallback:nil];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = anchorLeftButton;

    UINib *cellNib = [UINib nibWithNibName:@"SpecialCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"SpecialCell"];

    
//    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithTitle:@"Delete"
//                                                        style:UIBarButtonItemStylePlain
//                                                       target:self
//                                                       action:@selector(settingsPressed)];
    
//    self.navigationItem.rightBarButtonItem = delete;
    
    
}

- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;

    self.tableArray = [ProximityKitManager shared].compaignArray;
    [_collectionView reloadData];

}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}


#pragma mark - Actions

- (void) backAction: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    
    NSInteger count = [self.tableArray count];
    
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
    [cell setupCampaign:[_tableArray safeObjectAtIndex:indexPath.row]];
    
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


@end
