//
//  SearchView.m
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/15/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import "SearchView.h"
#import "TMQuiltView.h"
#import "CategoryItemCell.h"

@interface SearchView ()
<TMQuiltViewDataSource,
TMQuiltViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *allCategoriesButton;

@property (strong, nonatomic) TMQuiltView* quiltView;
@property (strong, nonatomic) NSMutableArray* collectionArray;
@end

@implementation SearchView


- (void)awakeFromNib{
    
    [self setupCollection];

    self.collectionArray = [@[@{@"name":@"Antiques",
                               @"id":@"122",
                                @"image":@""},
                             
                              @{@"name":@"Women's Apparel",
                               @"id":@"59",
                               @"image":@"Women's Apparel"},
                             
                              @{@"name":@"Bakery",
                               @"id":@"31",
                               @"image":@""},
                             
                              @{@"name":@"Beauty",
                               @"id":@"73",
                               @"image":@""},
                             
                              @{@"name":@"Bookstore",
                               @"id":@"128",
                               @"image":@"Books"},
                             
                              @{@"name":@"Bridal",
                               @"id":@"49",
                               @"image":@"bridal"},
                             
                              @{@"name":@"Café",
                               @"id":@"133",
                               @"image":@"coffe"},
                              
                             @{@"name":@"Children",
                               @"id":@"40",
                               @"image":@"children"},
                              
                             @{@"name":@"Consigment",
                               @"id":@"45",
                               @"image":@""},
                              
                             @{@"name":@"Fitness",
                               @"id":@"165",
                               @"image":@"Fitness"},
                              
                             @{@"name":@"Florist",
                               @"id":@"63",
                               @"image":@"flower"},
                              
                             @{@"name":@"Gallery",
                               @"id":@"141",
                               @"image":@""},
                              
                             @{@"name":@"Gifts",
                               @"id":@"67",
                               @"image":@"Gifts"},
                              
                             @{@"name":@"Hardware",
                               @"id":@"68",
                               @"image":@""},
                              
                             @{@"name":@"Home Goods",
                               @"id":@"145",
                               @"image":@"homegoods"},
                              
                             @{@"name":@"Jewelry",
                               @"id":@"69",
                               @"image":@"Jewelry"},
                              
                             @{@"name":@"Outdoor",
                               @"id":@"75",
                               @"image":@""},
                              
                             @{@"name":@"Realtors",
                               @"id":@"152",
                               @"image":@""},
                              
                             @{@"name":@"Restaurant",
                               @"id":@"153",
                               @"image":@""},
                              
                             @{@"name":@"Shoes",
                               @"id":@"155",
                               @"image":@"Shoes"},
                              
                             @{@"name":@"Spirits",
                               @"id":@"126",
                               @"image":@""},
                              
                             @{@"name":@"Sweets",
                               @"id":@"114",
                               @"image":@""},
                              
                             @{@"name":@"Tattoo",
                               @"id":@"158",
                               @"image":@""},
                              
                             @{@"name":@"Theater",
                               @"id":@"159",
                               @"image":@""}] mutableCopy];
    [self sortDataAssending:YES];
    [_quiltView setScrollEnabled:NO];
}

- (void)setupCollection{
    
    CGRect rc = self.bounds;
    rc.origin.y = CGRectGetMaxY(_allCategoriesButton.frame);
    
    rc.size.height -= rc.origin.y;
    
    
    self.quiltView = [[TMQuiltView alloc] initWithFrame:rc];
    _quiltView.delegate = self;
    _quiltView.dataSource = self;
    _quiltView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_quiltView];
    _quiltView.backgroundColor = [UIColor clearColor];
    
    self.backgroundColor = [UIColor clearColor];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
//        CGRect rc = self.bounds;
//    
//        rc.size.width -= 250;
//        _quiltView.frame = rc;
}

- (void)sortDataAssending:(BOOL)value{
    
    [_collectionArray sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
        NSString *first = [obj1 safeStringObjectForKey:@"name"];
        NSString *second = [obj2 safeStringObjectForKey:@"name"];
        
        if (value) {
            return [second caseInsensitiveCompare:first];
        }else{
            return [first caseInsensitiveCompare:second];
        }
    }];
    
    [_quiltView reloadData];
}



#pragma mark - QuiltViewControllerDataSource


- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView {
    return _collectionArray.count;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CategoryItemCell *cell = (CategoryItemCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"CategoryItemCell"];
    if (!cell) {
        cell = [CategoryItemCell loadViewFromXIB];
        [cell setReuseIdentifier:@"CategoryItemCell"];
    }
    
    
    NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
    NSString* name = [storeDict safeStringObjectForKey:@"name"];
    cell.descrLabel.text = name;
    
    NSString* imageName = [storeDict safeStringObjectForKey:@"image"];
    UIImage* image = [UIImage imageNamed:imageName];
    cell.logoImageView.image = image;
    cell.logoImageView.hidden = YES;
    return cell;
    
}


#pragma mark - TMQuiltViewDelegate

- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
    if (_didSelectCategory) {
        _didSelectCategory(self, dict);
    }
    
}

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView {
    
    return 3;
   
}

//// Must return margins for all the possible values of TMQuiltViewMarginType. Otherwise a default value is used.
//- (CGFloat)quiltViewMargin:(TMQuiltView *)quilView marginType:(TMQuiltViewMarginType)marginType{
//    return TMQuiltViewCellMarginColumns;
//}


- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSDictionary* storeDict = [_collectionArray safeDictionaryObjectAtIndex:indexPath.row];
    
    CGFloat height = 70;
    
    return height;
}

- (IBAction)allCategoriesButtonClicked:(id)sender {
    if (_didSelectAllCategory) {
        _didSelectAllCategory(self, nil);
    }
}

@end
