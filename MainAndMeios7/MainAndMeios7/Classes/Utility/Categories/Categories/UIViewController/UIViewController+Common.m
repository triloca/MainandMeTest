//
//  UIViewController+Common.m
//  MainAndMe
//
//  Created by Sasha on 3/11/13.
//
//

#import "UIViewController+Common.h"

@implementation UIViewController (Common)


+ (id)loadFromXIBForScrrenSizes{

    if (IS_IPHONE_4_OR_LESS) {
        NSString* xibName = [NSString stringWithFormat:@"%@", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
        
        return nil;
    }
    
    if (IS_IPHONE_5) {
        
        NSString* xibName = [NSString stringWithFormat:@"%@_568h", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
        
        xibName = [NSString stringWithFormat:@"%@", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
        
        return nil;
    }
    
    if (IS_IPHONE_6) {
        
        NSString* xibName = [NSString stringWithFormat:@"%@_667h", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
        
        xibName = [NSString stringWithFormat:@"%@_568h", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
        
        xibName = [NSString stringWithFormat:@"%@", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
        
        return nil;
    }
    
    if (IS_IPHONE_6P) {
        
        NSString* xibName = [NSString stringWithFormat:@"%@_736h", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
        
        xibName = [NSString stringWithFormat:@"%@_667h", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
        
        xibName = [NSString stringWithFormat:@"%@_568h", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
        
        xibName = [NSString stringWithFormat:@"%@", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
        
        return nil;
    }

    
    return nil;
}

+ (id)loadFromXIB_Or_iPhone5_XIB{
    
    BOOL isScreen568 = (fabs((double)[[ UIScreen mainScreen] bounds].size.height - (double)568 ) < DBL_EPSILON );
    BOOL isIOS7OrLater = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f);
    
    if(isScreen568){
        
        NSString* xibName = [NSString stringWithFormat:@"%@_iPhone5_iOS7", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName] && isIOS7OrLater) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
        
        xibName = [NSString stringWithFormat:@"%@_iPhone5", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
        
        xibName = [NSString stringWithFormat:@"%@", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
    
    }else{
       
        NSString* xibName = [NSString stringWithFormat:@"%@_iOS7", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName] && isIOS7OrLater) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }

        xibName = [NSString stringWithFormat:@"%@", NSStringFromClass(self)];
        if ([self isXibFileWithName:xibName]) {
            return [[self alloc] initWithNibName:xibName bundle:nil];
        }
    }
    
    return nil;
}


+ (BOOL)isXibFileWithName:(NSString*)name{
    
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:name
                      ofType:@"nib"];
    if (path) {
        return YES;
    }
    return NO;
}

@end
