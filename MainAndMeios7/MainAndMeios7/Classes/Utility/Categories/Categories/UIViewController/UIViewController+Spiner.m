//
//  UIViewController+Spiner.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "UIViewController+Spiner.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@interface UIViewController (_Spiner)
@property (readwrite, nonatomic, retain, setter = un_setSpinerView:) UIActivityIndicatorView* un_spinerView;
@property (readwrite, nonatomic, retain, setter = un_setSpinerBackgroundView:) UIView* un_spinerBackgroundView;
@property (readwrite, nonatomic, retain, setter = un_setSpinerNameDictionary:) NSMutableDictionary* un_spinerNameDictionary;
@end

@implementation UIViewController (_Spiner)
@dynamic un_spinerView;
@dynamic un_spinerBackgroundView;
@dynamic un_spinerNameDictionary;
@end


static char kUNSpinerViewObjectKey;
static char kUNSpinerBackgroundViewObjectKey;
static char kUNSpinerNameDictionaryObjectKey;

@implementation UIViewController (Spiner)

- (void)un_setSpinerView:(UIActivityIndicatorView *)spinerView{
    objc_setAssociatedObject(self, &kUNSpinerViewObjectKey, spinerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (UIActivityIndicatorView *)un_spinerView {
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, &kUNSpinerViewObjectKey);
}


- (void)un_setSpinerBackgroundView:(UIActivityIndicatorView *)spinerBackgroundView{
    objc_setAssociatedObject(self, &kUNSpinerBackgroundViewObjectKey, spinerBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (UIView *)un_spinerBackgroundView {
    return (UIView *)objc_getAssociatedObject(self, &kUNSpinerBackgroundViewObjectKey);
}


- (void)un_setSpinerNameDictionary:(NSDictionary *)dictionary{
    objc_setAssociatedObject(self, &kUNSpinerNameDictionaryObjectKey, dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSMutableDictionary *)un_spinerNameDictionary {
    return (NSMutableDictionary *)objc_getAssociatedObject(self, &kUNSpinerNameDictionaryObjectKey);
}


- (void)showSpinnerWithName:(NSString*)name{
    [self showSpinnerWithName:name andStyle:UIActivityIndicatorViewStyleWhiteLarge];
}


- (void)showSpinnerWithName:(NSString *)name andStyle:(UIActivityIndicatorViewStyle)style{
    [self showSpinnerWithName:name andStyle:style insets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
}

- (void)showSpinnerWithName:(NSString *)name andStyle:(UIActivityIndicatorViewStyle)style insets:(UIEdgeInsets)insets{
    
    if (!name) {
        return;
    }
    
    if (self.un_spinerBackgroundView == nil) {
        [self createSpinerBackgroundView];
    }
    
    if (self.un_spinerView == nil) {
        [self createSpinerViewWithStyle:style insets:insets];
    }
    
    if (self.un_spinerNameDictionary == nil) {
        self.un_spinerNameDictionary = [NSMutableDictionary dictionary];
    }
    
    NSNumber* number = [self.un_spinerNameDictionary objectForKey:name];
    
    if (!number) {
        number = [NSNumber numberWithInt:1];
    }else {
        number = [NSNumber numberWithInt:[number intValue] + 1];
    }
    
    [self.un_spinerNameDictionary setObject:number forKey:name];
}


//- (void)showSpinnerWithName:(NSString *)name andStyle:(UIActivityIndicatorViewStyle)style insets:(UIEdgeInsets)insets{
//    
//    if (!name) {
//        return;
//    }
//    
//    if (self.un_spinerBackgroundView == nil) {
//        [self createSpinerBackgroundView];
//    }
//    
//    if (self.un_spinerView == nil) {
//        [self createSpinerViewWithStyle:style insets:insets];
//    }
//    
//    if (self.un_spinerNameDictionary == nil) {
//        self.un_spinerNameDictionary = [NSMutableDictionary dictionary];
//    }
//    
//    NSNumber* number = [self.un_spinerNameDictionary objectForKey:name];
//    
//    if (!number) {
//        number = [NSNumber numberWithInt:1];
//    }else {
//        number = [NSNumber numberWithInt:[number intValue] + 1];
//    }
//    
//    [self.un_spinerNameDictionary setObject:number forKey:name];
//}


- (void)hideSpinnerWithName:(NSString *)name{
    
    if (!name || self.un_spinerNameDictionary == nil) {
        return;
    }
    
    NSNumber* number = [self.un_spinerNameDictionary objectForKey:name];
    
    if ([number intValue] > 1){
        number = [NSNumber numberWithInt:[number intValue] - 1];
        [self.un_spinerNameDictionary setObject:number forKey:name];
        return;
        
    }else {
        [self.un_spinerNameDictionary removeObjectForKey:name];
    }
    
    if([[self.un_spinerNameDictionary allValues] count] == 0){
        [self.un_spinerView stopAnimating];
        [self.un_spinerView removeFromSuperview];
        [self.un_spinerBackgroundView removeFromSuperview];
        self.un_spinerBackgroundView = nil;
        self.un_spinerView = nil;
        self.un_spinerNameDictionary = nil;
    }
}


- (void)hideAllSpiners{
    
    [self.un_spinerView stopAnimating];
    [self.un_spinerView removeFromSuperview];
    [self.un_spinerBackgroundView removeFromSuperview];
    self.un_spinerBackgroundView = nil;
    self.un_spinerView = nil;
    self.un_spinerNameDictionary = nil;
}

- (void)createSpinerViewWithStyle:(UIActivityIndicatorViewStyle)style insets:(UIEdgeInsets)insets{
    
    CGRect rc;
    if (style == UIActivityIndicatorViewStyleWhiteLarge) {
        rc = CGRectMake(0, 0, 36, 36);
    }else {
        rc = CGRectMake(0, 0, 21, 21);
    }
    
    self.un_spinerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    self.un_spinerView.frame = rc;
    self.un_spinerView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    self.un_spinerView.contentMode = UIViewContentModeCenter;
    [self.un_spinerView startAnimating];
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    backgroundView.backgroundColor = [UIColor colorWithRed:10/255.0f green:110/255.0f blue:10/255.0f alpha:0.5f];
    
    backgroundView.layer.cornerRadius = 10;
    backgroundView.center = CGPointMake(CGRectGetMidX(self.un_spinerView.bounds), CGRectGetMidY(self.un_spinerView.bounds));
    
    [self.un_spinerView addSubview:backgroundView];
    [self.un_spinerView sendSubviewToBack:backgroundView];
    
    [self.view addSubview:self.un_spinerView];
    
    [self.view bringSubviewToFront:self.un_spinerView];
    
    
    rc = self.un_spinerView.frame;
    rc.origin.x += insets.left;
    rc.origin.y += insets.top;
    self.un_spinerView.frame = rc;
    
//    rc = backgroundView.frame;
//    rc.origin.x += insets.left;
//    rc.origin.y += insets.top;
//    backgroundView.frame = rc;
}


- (void)createSpinerBackgroundView{
    
    self.un_spinerBackgroundView = [[UIView alloc] init];
    self.un_spinerBackgroundView.frame = self.view.bounds;
    self.un_spinerBackgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.un_spinerBackgroundView.userInteractionEnabled = YES;
    self.un_spinerBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.un_spinerBackgroundView];
    
    [self.view bringSubviewToFront:self.un_spinerBackgroundView];
}

@end
