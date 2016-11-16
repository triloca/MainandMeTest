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


@interface IntroViewController ()
@property (strong, nonatomic) NSMutableArray* collectionArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSTimer *timer;


@end

@implementation IntroViewController

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
                                      @"ImageName" : @"0-Main&Me Tutorial-TIFFs.002.tiff"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"0-Main&Me Tutorial-TIFFs.003.tiff"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"0-Main&Me Tutorial-TIFFs.004.tiff"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"0-Main&Me Tutorial-TIFFs.005.tiff"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"0-Main&Me Tutorial-TIFFs.006.tiff"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"0-Main&Me Tutorial-TIFFs.007.tiff"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroCell",
                                      @"CellIdentifier" : @"IntroCell",
                                      @"ImageName" : @"0-Main&Me Tutorial-TIFFs.008.tiff"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroEndCell",
                                      @"CellIdentifier" : @"IntroEndCell",
                                      @"ImageName" : @"0-Main&Me Tutorial-TIFFs.009.tiff"}];

    [self startTimer];
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
    
    NSDictionary* cellInfo = _collectionArray[indexPath.row];
    
    NSString *cellType = cellInfo[@"CellType"];
    NSString *cellIdentifier = cellInfo[@"CellIdentifier"];
    NSString* imageName = cellInfo[@"ImageName"];
    
    IntroCell *cell = (IntroCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.contentImageView.image = [UIImage imageNamed:imageName];
    
    if ([cellType isEqualToString:@"IntroEndCell"]) {
        IntroEndCell* introEndCell = (IntroEndCell*)cell;
        introEndCell.didClickEndTutorial = ^(IntroEndCell* obj){
            [self dismissViewControllerAnimated:YES completion:nil];
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



@end
