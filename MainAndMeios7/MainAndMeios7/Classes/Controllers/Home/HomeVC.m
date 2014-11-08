//
//  HomeVC.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 10/19/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "HomeVC.h"
#import "UIFont+All.h"
#import "SearchTypeView.h"
#import "SearchTypeView.h"
#import "TMQuiltView.h"
#import "HomeCell.h"
#import "LoadProductsRequest.h"

@interface HomeVC () <TMQuiltViewDataSource, TMQuiltViewDelegate>
@property (strong, nonatomic) SearchTypeView *searchTypeView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@property (strong, nonatomic) TMQuiltView *quiltView;
@property (strong, nonatomic) NSMutableArray* collectionArray;

@end

@implementation HomeVC

#pragma mark _______________________ Class Methods _________________________
#pragma mark ____________________________ Init _____________________________
#pragma mark _______________________ View Lifecycle ________________________

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton* menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"menu_button.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 40, 40);
    [menuButton addTarget:self action:@selector(anchorRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *anchorLeftButton  = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    
    self.searchTypeView = [SearchTypeView loadViewFromXIB];
    [self.view addSubview:_searchTypeView];
    
    [self configSearchBar];
    
    self.navigationItem.title = @"Layout Demo";
    self.navigationItem.leftBarButtonItem = anchorLeftButton;
    
    [_searchTypeView selectItems];

    [self setupCollection];
    
//    _collectionArray = @[
//                         @{@"height" : [NSNumber numberWithFloat:200],
//                           @"image": [UIImage imageNamed:@"big_IMG_2423.jpg"]},
//                         @{@"height" : [NSNumber numberWithFloat:250],
//                           @"image": [UIImage imageNamed:@"big_IMG_2952.jpg"]},
//                         @{@"height" : [NSNumber numberWithFloat:230],
//                           @"image": [UIImage imageNamed:@"big_IMG_4133.jpg"]},
//                         @{@"height" : [NSNumber numberWithFloat:205],
//                           @"image": [UIImage imageNamed:@"big_IMG_5648.jpg"]},
//                         @{@"height" : [NSNumber numberWithFloat:220],
//                           @"image": [UIImage imageNamed:@"big_IMG_4133.jpg"]},
//                         @{@"height" : [NSNumber numberWithFloat:260],
//                           @"image": [UIImage imageNamed:@"big_IMG_5648.jpg"]},
//                         @{@"height" : [NSNumber numberWithFloat:200],
//                           @"image": [UIImage imageNamed:@"big_IMG_2952.jpg"]},
//                         @{@"height" : [NSNumber numberWithFloat:270],
//                           @"image": [UIImage imageNamed:@"big_IMG_2952.jpg"]},
//                         @{@"height" : [NSNumber numberWithFloat:310],
//                           @"image": [UIImage imageNamed:@"big_IMG_4133.jpg"]},
//                         @{@"height" : [NSNumber numberWithFloat:235],
//                           @"image": [UIImage imageNamed:@"big_IMG_2423.jpg"]},
//                         @{@"height" : [NSNumber numberWithFloat:240],
//                           @"image": [UIImage imageNamed:@"big_IMG_4133.jpg"]},
//                         @{@"height" : [NSNumber numberWithFloat:200],
//                           @"image": [UIImage imageNamed:@"big_IMG_2952.jpg"]}
//                         
//                         ];
    
    
    self.collectionArray = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_quiltView reloadData];
    
    [self search];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self updateSearchTypeViewFrame];
    [self configureCollectionFrame];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark _______________________ Privat Methods(view)___________________


- (void)anchorRight {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)updateSearchTypeViewFrame{
    CGRect rc = _searchTypeView.frame;
    rc.origin.y = 0;
    _searchTypeView.frame = rc;
    
}

- (void)configSearchBar{

    UIView* topCoverView = [UIView new];
    topCoverView.backgroundColor = [UIColor colorWithRed:0.929f green:0.925f blue:0.925f alpha:1.00f];
    topCoverView.frame = CGRectMake(0, 0, _searchBar.frame.size.width, 1);
    topCoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchBar addSubview:topCoverView];
    
    UIView* bottomCoverView = [UIView new];
    bottomCoverView.backgroundColor = [UIColor colorWithRed:0.929f green:0.925f blue:0.925f alpha:1.00f];
    bottomCoverView.frame = CGRectMake(0, _searchBar.frame.size.height - 1, _searchBar.frame.size.width, 1);
    bottomCoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchBar addSubview:bottomCoverView];
    
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"scope_bar_background.png"]forState:UIControlStateNormal];
    
    CGRect rc = _searchBar.frame;
    rc.origin.y = CGRectGetMaxY(_searchTypeView.frame);
    _searchBar.frame = rc;
}


- (void)setupCollection{
    
    self.quiltView = [[TMQuiltView alloc] initWithFrame:CGRectZero];
    _quiltView.delegate = self;
    _quiltView.dataSource = self;
    _quiltView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_quiltView];
    _quiltView.backgroundColor = [UIColor clearColor];

}

- (void)configureCollectionFrame{
    
    CGRect rc = self.view.frame;
    rc.origin.y = CGRectGetMaxY(_searchBar.frame);
    rc.size.height -= rc.origin.y;
    _quiltView.frame = rc;

}

#pragma mark _______________________ Privat Methods ________________________


- (void)search{
    if (_searchTypeView.searchType == SearchTypeItems) {
        [self loadProducts];
    }
}

- (void)loadProducts{

    LoadProductsRequest *request = [[LoadProductsRequest alloc] init];
    request.keywords = @"find";

    [self showSpinnerWithName:@""];
    [[MMServiceProvider sharedProvider] sendRequest:request success:^(id _request) {
        [self hideSpinnerWithName:@""];
        NSLog(@"products: %@", request.products);
        
        [_collectionArray addObjectsFromArray:request.products];
        
        [_quiltView reloadData];
        
    } failure:^(id _request, NSError *error) {
        [self hideSpinnerWithName:@""];
        NSLog(@"error: %@", error);
    }];

}

#pragma mark _______________________ Buttons Action ________________________
#pragma mark _______________________ Delegates _____________________________

#pragma mark - QuiltViewControllerDataSource

//- (NSArray *)images {
//    if (!_images) {
//        NSMutableArray *imageNames = [NSMutableArray array];
//        for(int i = 0; i < kNumberOfCells; i++) {
//            [imageNames addObject:[NSString stringWithFormat:@"%d.jpeg", i % 10 + 1]];
//        }
//        _images = [imageNames retain];
//    }
//    return _images;
//}

//- (UIImage *)imageAtIndexPath:(NSIndexPath *)indexPath {
//    return [UIImage imageNamed:[self.images objectAtIndex:indexPath.row]];
//}


- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return _collectionArray.count;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    HomeCell *cell = (HomeCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"];
    if (!cell) {
        cell = [HomeCell loadViewFromXIB];
        [cell setReuseIdentifier:@"PhotoCell"];
    }
    
    
    cell.userNameLabel.text = @"James Akers";
    cell.descrLabel.text = @"Culture Clothing";
    cell.itemNameLabel.text = @"Clothing";
    
    NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
//    UIImage* image = [[_collectionArray safeDictionaryObjectAtIndex:indexPath.row] objectForKey:@"image"];
//    cell.mainImageView.image = image;
    
    cell.storeDict = storeDict;
    
    return cell;
}

#pragma mark - TMQuiltViewDelegate

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft
        || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        return 3;
    } else {
        return 2;
    }
}

- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
   CGFloat height = [HomeCell cellHeghtForStore:storeDict];
    
    return height;
}

#pragma mark _______________________ Public Methods ________________________
#pragma mark _______________________ Notifications _________________________
@end
