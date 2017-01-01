//
//  IntroViewController.m
//  MainAndMeios7
//
//  Created by Alexanedr on 11/13/16.
//  Copyright © 2016 Uniprog. All rights reserved.
//

#import "IntroPresentViewController.h"
#import "IntroPresentCell.h"
#import "IntroPresentEndCell.h"
#import "SMPageControl.h"
#import "ReadGetStartedViewController.h"
#import "hipmob/HMService.h"
#import "AppDelegate.h"


@interface IntroPresentViewController ()
@property (strong, nonatomic) NSMutableArray* collectionArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet SMPageControl *pageControl;

@end

@implementation IntroPresentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *cellNib = [UINib nibWithNibName:@"IntroPresentCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"IntroPresentCell"];
    
    cellNib = [UINib nibWithNibName:@"IntroPresentEndCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"IntroPresentEndCell"];

    
    self.collectionArray = @[].mutableCopy;
    [self.collectionArray addObject:@{@"CellType" : @"IntroPresentCell",
                                      @"CellIdentifier" : @"IntroPresentCell",
                                      @"ImageName" : @"12b-Benefits-Yourtown in your pocket.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroPresentCell",
                                      @"CellIdentifier" : @"IntroPresentCell",
                                      @"ImageName" : @"13-Benefits-Saves you thousands.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroPresentCell",
                                      @"CellIdentifier" : @"IntroPresentCell",
                                      @"ImageName" : @"14-Benefits-More foot traffic.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroPresentCell",
                                      @"CellIdentifier" : @"IntroPresentCell",
                                      @"ImageName" : @"15-Benefits-Wishlists.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroPresentCell",
                                      @"CellIdentifier" : @"IntroPresentCell",
                                      @"ImageName" : @"16-Benefits-Advertising channel.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroPresentCell",
                                      @"CellIdentifier" : @"IntroPresentCell",
                                      @"ImageName" : @"17-Benefits-Games for discovery.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroPresentCell",
                                      @"CellIdentifier" : @"IntroPresentCell",
                                      @"ImageName" : @"18-Benefits-Spoil sponsors.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroPresentEndCell",
                                      @"CellIdentifier" : @"IntroPresentEndCell",
                                      @"ImageName" : @"19b-Benefits-Crowdsourcing.png"}];
    
    [self.collectionArray addObject:@{@"CellType" : @"IntroPresentEndCell",
                                      @"CellIdentifier" : @"IntroPresentEndCell",
                                      @"ImageName" : @"20-End of Benefits.png"}];

    [self startTimer];
    
    //! Update page control view
    self.pageControl.numberOfPages = self.collectionArray.count;
    [self.pageControl setPageIndicatorImage:[UIImage imageNamed:@"pageDot"]];
    [self.pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"currentPageDot"]];
    
    [self updatePageControl];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self.collectionView reloadData];
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

- (IBAction)showChat{
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // open a chat view
    [[HMService sharedService] openChatWithPush:self withSetup:^(HMContentChatViewController * controller){
        // set the title of the chat window
        controller.title = @"Chat with an Operator";
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        
        //controller.navigationBar.barTintColor = [UIColor redColor];
        
        //controller.chatView.sentTextColor = [UIColor redColor];
        
        //controller.chatView.sendMedia.hidden = YES;
        
        //[controller.chatView setCustomData:@"Timestamp" forKey:@"Joined"];
        //[controller.chatView setCustomData:@"$100K" forKey:@"Budget"];
        
    } forApp:APPID];
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
    
    
    
    
    if ([cellType isEqualToString:@"IntroPresentCell"]) {
        IntroPresentCell *cell = (IntroPresentCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        cell.contentImageView.image = [UIImage imageNamed:imageName];
        
        cell.didClickHomeButton = ^(IntroPresentCell* sender){
            if (self.didClickHome) {
                self.didClickHome(self);
            }
        };
        
        cell.didClickChatButton = ^(IntroPresentCell* sender){
            [self showChat];
        };
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        return cell;

    }else

    if ([cellType isEqualToString:@"IntroPresentEndCell"]) {
        IntroPresentEndCell *introEndCell = (IntroPresentEndCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        introEndCell.contentImageView.image = [UIImage imageNamed:imageName];
        
        introEndCell.didClickEndTutorial = ^(IntroPresentEndCell* obj){
            [wSelf dismissViewControllerAnimated:YES completion:^{}];
        };
        
        introEndCell.didClickReadGetStarted = ^(IntroPresentEndCell* obj){
            ReadGetStartedViewController* readGetStartedViewController = [ReadGetStartedViewController loadFromXIBForScrrenSizes];
            [wSelf.navigationController pushViewController:readGetStartedViewController animated:YES];
        };
        
        introEndCell.didClickAddItem = ^(IntroPresentEndCell* obj){
            if (_didClickAddItem) {
                _didClickAddItem(wSelf);
            }
        };
        
        introEndCell.didClickAddLocalBussines = ^(IntroPresentEndCell* obj){
            if (_didClickAddLocalBussines) {
                _didClickAddLocalBussines(wSelf);
            }
        };
        
        introEndCell.didClickWindshop = ^(IntroPresentEndCell* obj){
            if (_didClickWindshop) {
                _didClickWindshop(wSelf);
            }
        };
        
        introEndCell.didClickChat = ^(IntroPresentEndCell* obj){
            // open a chat view
            [wSelf.navigationController setNavigationBarHidden:NO animated:NO];

            [[HMService sharedService] openChatWithPush:self withSetup:^(HMContentChatViewController * controller){
                // set the title of the chat window
                controller.title = @"Chat with an Operator";
                [controller.navigationController setNavigationBarHidden:NO animated:NO];
                //controller.navigationBar.barTintColor = [UIColor redColor];
                
                //controller.chatView.sentTextColor = [UIColor redColor];
                
                //controller.chatView.sendMedia.hidden = YES;
                
                //[controller.chatView setCustomData:@"Timestamp" forKey:@"Joined"];
                //[controller.chatView setCustomData:@"$100K" forKey:@"Budget"];
                
            } forApp:APPID];

        };
        
        [introEndCell setNeedsLayout];
        [introEndCell layoutIfNeeded];
        
        return introEndCell;


    }
    
    return nil;
    
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
