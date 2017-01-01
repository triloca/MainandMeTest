//
//  IntroViewController.m
//  MainAndMeios7
//
//  Created by Alexanedr on 11/13/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import "IntroViewController.h"
#import "IntroCell.h"
#import "IntroEndCell.h"
#import "SMPageControl.h"


@interface IntroViewController ()
@property (strong, nonatomic) NSMutableArray* collectionArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSTimer *timer;
    @property (weak, nonatomic) IBOutlet SMPageControl *pageControl;


@end

@implementation IntroViewController

    + (BOOL)wasShown{
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"kIntroWasShown"];
    }
    
    + (void)setWasShown:(BOOL)value{
        [[NSUserDefaults standardUserDefaults] setBool:value forKey:@"kIntroWasShown"];
    }
    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *cellNib = [UINib nibWithNibName:@"IntroCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"IntroCell"];
    
    cellNib = [UINib nibWithNibName:@"IntroEndCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"IntroEndCell"];

    self.collectionArray = @[].mutableCopy;
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"1-Welcome.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"2-Windowshop.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"3-Specials.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"4-Events.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"5-Exchange wishlists.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"6-Add photos of finds.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"7-Scavenger hunts.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"8-Browse any city.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroEndCell",
                                      @"CellIdentifier" : @"IntroEndCell",
                                      @"ImageName" : @"9-End of tutorial.png"}];

    //[self startTimer];
    
    //! Update page control view
    self.pageControl.numberOfPages = self.collectionArray.count;
    [self.pageControl setPageIndicatorImage:[UIImage imageNamed:@"pageDot"]];
    [self.pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"currentPageDot"]];

    [self updatePageControl];

}

#pragma mark Page control
- (void)updatePageControl{
    NSInteger currentPage = (NSInteger)((self.collectionView.contentOffset.x + self.collectionView.frame.size.width / 2)/ self.collectionView.frame.size.width);
    [self.pageControl setCurrentPage:currentPage];
    
    if (currentPage == self.collectionArray.count - 1) {
        self.pageControl.alpha = 0;
    }else{
        self.pageControl.alpha = 1;
    }
}
    
- (void) startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
}

- (void) stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void) timerTick: (NSTimer *) timer {
    [self scrollToNext];
}

- (void)scrollToNext{
    NSIndexPath* indexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
    
    if (indexPath && indexPath.row < _collectionArray.count - 1) {
        NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
        
        [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) wSelf = self;
    NSDictionary* cellInfo = _collectionArray[indexPath.row];
    
    NSString *cellType = cellInfo[@"CellType"];
    NSString *cellIdentifier = cellInfo[@"CellIdentifier"];
    NSString* imageName = cellInfo[@"ImageName"];
    
    IntroCell *cell = (IntroCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.contentImageView.image = [UIImage imageNamed:imageName];
    
    if ([cellType isEqualToString:@"IntroCell"]) {
        
        if (indexPath.row == 0){
            cell.skipButton.hidden = NO;
        }else{
            cell.skipButton.hidden = YES;
        }
            
        
        cell.didClickEndTutorial = ^(IntroCell* obj){
            NSIndexPath* iP = [NSIndexPath indexPathForItem:self.collectionArray.count - 1 inSection:0];

            [self.collectionView scrollToItemAtIndexPath:iP
                                   atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                           animated:YES];
        };
    }
    
    if ([cellType isEqualToString:@"IntroEndCell"]) {
        IntroEndCell* introEndCell = (IntroEndCell*)cell;
        
        introEndCell.didClickEndTutorial = ^(IntroEndCell* obj){
            if (_didClickEndTutorial) {
                _didClickEndTutorial(wSelf);
            }
        };
                
        introEndCell.didClickSeeTowns = ^(IntroEndCell* obj){
            if (_didClickSeeTowns) {
                _didClickSeeTowns(wSelf);
            }
        };

        introEndCell.didClickAddItem = ^(IntroEndCell* obj){
            if (_didClickAddItem) {
                _didClickAddItem(wSelf);
            }
        };

        introEndCell.didClickAddLocalBussines = ^(IntroEndCell* obj){
            if (_didClickAddLocalBussines) {
                _didClickAddLocalBussines(wSelf);
            }
        };

        introEndCell.didClickWindshop = ^(IntroEndCell* obj){
            if (_didClickWindshop) {
                _didClickWindshop(wSelf);
            }
        };

        introEndCell.didClickSeeBenefits = ^(IntroEndCell* obj){
            if (_didClickSeeBenefits) {
                _didClickSeeBenefits(wSelf);
            }
        };
        
        introEndCell.didClickBack = ^(IntroEndCell* obj){
            NSIndexPath* iP = [NSIndexPath indexPathForItem:self.collectionArray.count - 2 inSection:0];
            
            [self.collectionView scrollToItemAtIndexPath:iP
                                        atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                animated:YES];
        };


    }
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}

- (void)scrollViewDidEndDecelerating: (UIScrollView *)scrollView {
    [self startTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self updatePageControl];
}


@end
