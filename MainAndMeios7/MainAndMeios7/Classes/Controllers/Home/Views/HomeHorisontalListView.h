//
//  HomeHorisontalListView.h
//  MainAndMeios7
//
//  Created by Alexander Bukov on 11/15/14.
//  Copyright (c) 2014 Uniprog. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HorisontalListViewDelegate;

@interface HomeHorisontalListView : UIView


@property (strong, nonatomic) NSArray* tableArray;

@property (weak, nonatomic, readonly) UICollectionView *collectionView;

@property (copy, nonatomic) void (^didSelectItem)(HomeHorisontalListView* view, NSDictionary* itemDict);

@property (assign) NSObject <HorisontalListViewDelegate> *delegate;

- (void) reloadData;



@end


@protocol HorisontalListViewDelegate

- (void) horisontalListViewdidScrollToEnd: (HomeHorisontalListView *) listView ;

@end