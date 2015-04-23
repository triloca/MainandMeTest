//
//  TMQuiltViewCell.m
//  TMQuiltView
//
//  Created by Bruno Virlet on 7/20/12.
//
//  Copyright (c) 2012 1000memories

//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO 
//  EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR 
//  THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "TMQuiltViewCell.h"

@interface TMQuiltViewCell ()
@end

@implementation TMQuiltViewCell

@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize selected = _selected;

- (void)dealloc {
    [_reuseIdentifier release], _reuseIdentifier = nil;
    
    [super dealloc];
}

- (void) initialize {
    if (! self.editingButton) {
        self.editingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [UIImage imageNamed:@"remove_x3_50"];
        [_editingButton setImage:img forState:UIControlStateNormal];
        [_editingButton setFrame:CGRectMake(0, 0, img.size.width / 2, img.size.height / 2)];
        [self addSubview:_editingButton];
    }
    self.editing = NO;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super init];
    if (self) {
        _reuseIdentifier = [reuseIdentifier retain];
        [self initialize];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGFloat w = _editingButton.frame.size.width;
    CGFloat h = _editingButton.frame.size.height;
    CGFloat x = self.frame.size.width - w - 5;
    CGFloat y = 0 + 5;
    _editingButton.frame = CGRectMake(x, y, w, h);
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void) setEditing:(BOOL)editing {
    if (_editing == editing && editing == YES)
        return;
    
    _editing = editing;
    if (_editing) {
        [self startJiggling:1];
        _editingButton.alpha = 1;
    } else {
        [self stopJiggling];
        _editingButton.alpha = 0;
    }
}
//
//- (void) startJiggling: (int) not {
//        CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//        [anim setToValue:[NSNumber numberWithFloat:-M_PI/64]];
//        [anim setFromValue:[NSNumber numberWithDouble:M_PI/64]];
//        [anim setDuration:0.2];
//        [anim setRepeatCount:NSUIntegerMax];
//        [anim setAutoreverses:YES];
//        [self.layer addAnimation:anim forKey:@"SpringboardShake"];
//}

#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 0.1
#define kAnimationTranslateX 0.0
#define kAnimationTranslateY 0.0

- (void)startJiggling:(NSInteger)count {
    CGAffineTransform leftWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg * (count%2 ? +1 : -1 ) ));
    CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg * (count%2 ? -1 : +1 ) ));
    self.transform = leftWobble;  // starting point
    
    [UIView animateWithDuration:0.1
                          delay:(count * 0.08)
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{ self.transform = rightWobble; }
                     completion:nil];
}

- (void)stopJiggling {
    self.clipsToBounds = YES;
    [self.layer removeAllAnimations];
    self.transform = CGAffineTransformIdentity;  // Set it straight
}

- (void)setReuseIdentifier:(NSString *)reuseIdentifier{
    _reuseIdentifier = [reuseIdentifier retain];
}

@end
