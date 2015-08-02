//
//  MyPhotosVC.m
//  MainAndMeios7
//
//  Created by Vladislav Zozulyak on 11.11.14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "MyPhotosVC.h"
#import "CustomTitleView.h"
#import "ProductCell.h"
#import "MyPhoto.h"
#import "MyPhotoDetailsVC.h"
#import "ProductsStoresManager.h"

static NSString *kProductCellIdentifier = @"ProductCell";

@interface MyPhotosVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* tableArray;
@property (assign, nonatomic) BOOL isEditing;


@end

@implementation MyPhotosVC

- (void)dealloc{

}

#pragma mark - Init


#pragma mark - View lifecycle
//
//- (void) viewDidLayoutSubviews {
//    if (self.gradient)
//        return;
//    
//    self.gradient = [CAGradientLayer layer];
//    _gradient.frame = CGRectMake(0, 0, _gradientView.frame.size.width, _gradientView.frame.size.height);
//    _gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.8] CGColor], nil];
//    
//    [_gradientView.layer insertSublayer:_gradient atIndex:0];
//    [self.view sendSubviewToBack:_gradientView];
//    [self.view sendSubviewToBack:_imageView];
//    [self.view setNeedsLayout];
//}

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak MyPhotosVC* wSelf = self;
    
    self.navigationItem.titleView = [[CustomTitleView alloc] initWithTitle:@"My photos" dropDownIndicator:NO clickCallback:^(CustomTitleView *titleView) {
        [[LayoutManager shared].homeNVC popToRootViewControllerAnimated:NO];
        [[LayoutManager shared] showHomeControllerAnimated:YES];
        [wSelf.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_button"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

//    MyPhoto* photo = [MyPhoto new];
//    photo.imagePath = @"";
//    
//    NSMutableArray* temp = [NSMutableArray arrayWithArray:[MyPhoto loadDataFromDisk]];
//    [temp insertObject:photo atIndex:0];
//    [MyPhoto saveMyPhotos:[NSArray arrayWithArray:temp]];
    

    [self updateData];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}


- (void)updateData{
    
    self.tableArray = [MyPhoto loadDataFromDisk];
    [self.tableView reloadData];
    [self updateEditButton];
}

#pragma mark - Actions

- (void) backAction: (id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)updateEditButton{
    
    if (_isEditing) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonClicked)];
    }else{
        if (_tableArray.count > 0) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                                      style:UIBarButtonItemStyleBordered
                                                                                     target:self
                                                                                     action:@selector(editButtonClicked)];
        }else{
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
        }
        
    }
}

- (void)editButtonClicked{
    self.isEditing = !self.isEditing;
    [self.tableView reloadData];
    [self updateEditButton];
}

- (IBAction)onShareButton:(id)sender {
    [[AlertManager shared] showOkAlertWithTitle:@"Question" message:@"What should be shared?"];
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return tableView.frame.size.width / 3 + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [_tableArray count];
    NSInteger temp = count % 3;
    NSInteger rowsCount = count / 3;
    if (temp > 0) {
        rowsCount++;
    }
    
    [self updateEditButton];
    
    return rowsCount;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProductCell* cell = [self productCellForIndexPath:indexPath];
    return cell;
}

- (ProductCell*)productCellForIndexPath:(NSIndexPath*)indexPath{
    ProductCell *cell = [_tableView dequeueReusableCellWithIdentifier:kProductCellIdentifier];
    
    if (_isEditing) {
        [cell.firstView startVibration];
        [cell.secondView startVibration];
        [cell.thirdView startVibration];
    }else{
        [cell.firstView stopVibration];
        [cell.secondView stopVibration];
        [cell.thirdView stopVibration];
    }

    
    if (cell == nil){
        cell = [ProductCell loadViewFromXIB];
        
        cell.didClickAtIndex = ^(NSInteger selectedIndex){
            NSDictionary* object = [_tableArray safeObjectAtIndex:selectedIndex];
            if (_isEditing) {
                //! Delete alert
                [[AlertManager shared] showAlertWithCallBack:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (alertView.cancelButtonIndex == buttonIndex) {
                        
                    }else{
                        
                        [[ProductsStoresManager shared] deleteProduct:[object objectForKey:@"id"]
                                                              success:^{
                                                                  
                                                              }
                                                              failure:^(NSError *error, NSString *errorString) {
                                                                  
                                                              }
                                                            exception:^(NSString *exceptionString) {
                                                                
                                                            }];
                        
                        [self updateData];
                    }
                }
                                                       title:@"Delete this photo?"
                                                     message:@""
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Delete", nil];
                
                
            }else{
                MyPhotoDetailsVC* vc = [MyPhotoDetailsVC loadFromXIBForScrrenSizes];
                vc.myPhoto = object;
                [self.navigationController pushViewController:vc animated:YES];
            }
        };
    }
    
    // Configure the cell...
    
    NSInteger index = indexPath.row * 3;
    
    if ([_tableArray count] > index) {
        MyPhoto* object = [_tableArray safeObjectAtIndex:index];
        
        [cell.firstView setimagePath:[object pathForLocalImage]];
        cell.firstView.hidden = NO;
        
    }else{
        cell.firstView.hidden = YES;
    }
    cell.firstView.coverButton.tag = index;
    
    if ([_tableArray count] > index + 1) {
        MyPhoto* object = [_tableArray safeObjectAtIndex:index + 1];
        
        [cell.secondView  setimagePath:[object pathForLocalImage]];
        cell.secondView.hidden = NO;
    }else{
        cell.secondView.hidden = YES;
    }
    cell.secondView.coverButton.tag = index + 1;
    
    if ([_tableArray count] > index + 2) {
        MyPhoto* object = [_tableArray safeObjectAtIndex:index + 2];
        
        [cell.thirdView  setimagePath:[object pathForLocalImage]];
        cell.thirdView.hidden = NO;
    }else{
        cell.thirdView.hidden = YES;
    }
    cell.thirdView.coverButton.tag = index + 2;
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

@end
