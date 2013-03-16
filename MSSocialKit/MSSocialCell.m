//
//  MSSocialCell.m
//  Pods
//
//  Created by Eric Horacek on 3/14/13.
//
//

#import "MSSocialCell.h"

@implementation MSSocialCell

#pragma mark - MSSocialCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _padding = UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0);
        _contentMargin = 1.0;
        _profileImageSize = CGSizeMake(1.0, 1.0);
    }
    return self;
}

#pragma mark - UIView

- (void)didMoveToSuperview
{
    [self updateConstraintsIfNeeded];
    
    if (NSClassFromString(self.backgroundViewClass)) {
        self.backgroundView = [[NSClassFromString(self.backgroundViewClass) alloc] init];
    }
    
    if (NSClassFromString(self.selectedBackgroundViewClass)) {
        self.backgroundView = [[NSClassFromString(self.selectedBackgroundViewClass) alloc] init];
    }
}

#pragma mark - MSSocialCell

+ (void)applyDefaultAppearance
{
    [self.appearance setPadding:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(14.0, 14.0, 14.0, 14.0) : UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0))];
    [self.appearance setContentMargin:10.0];
    [self.appearance setProfileImageSize:CGSizeMake(60.0, 60.0)];
    
    [self.appearance setBackgroundViewClass:NSStringFromClass(UIView.class)];
    
    [self.appearance setPrimaryTextAttributes:@{
        UITextAttributeFont: [UIFont boldSystemFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 16.0 : 15.0)],
        UITextAttributeTextColor: [UIColor whiteColor],
        UITextAttributeTextShadowColor: [UIColor blackColor],
        UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:CGSizeMake(0.0, 1.0)]
    }];
    
    [self.appearance setSecondaryTextAttributes:@{
        UITextAttributeFont: [UIFont systemFontOfSize:15.0],
        UITextAttributeTextColor: [UIColor grayColor],
        UITextAttributeTextShadowColor: [UIColor whiteColor],
        UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:CGSizeMake(0.0, 1.0)]
    }];
    
    [self.appearance setContentTextAttributes:@{
        UITextAttributeFont: [UIFont systemFontOfSize:15.0],
        UITextAttributeTextColor: [UIColor darkGrayColor],
        UITextAttributeTextShadowColor: [UIColor whiteColor],
        UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:CGSizeMake(0.0, 1.0)]
    }];
}

- (void)setPadding:(UIEdgeInsets)padding
{
    _padding = padding;
    [self setNeedsUpdateConstraints];
}

- (void)setContentMargin:(CGFloat)contentMargin
{
    _contentMargin = contentMargin;
    [self setNeedsUpdateConstraints];
}

- (void)setProfileImageSize:(CGSize)profileImageSize
{
    _profileImageSize = profileImageSize;
    [self setNeedsUpdateConstraints];
}

- (void)setPrimaryTextAttributes:(NSDictionary *)primaryTextAttributes
{
    _primaryTextAttributes = primaryTextAttributes;
    [self setNeedsUpdateConstraints];
}

- (void)setSecondaryTextAttributes:(NSDictionary *)secondaryTextAttributes
{
    _secondaryTextAttributes = secondaryTextAttributes;
    [self setNeedsUpdateConstraints];
}

- (void)setContentTextAttributes:(NSDictionary *)contentTextAttributes
{
    _contentTextAttributes = contentTextAttributes;
    [self setNeedsUpdateConstraints];
}

+ (CGFloat)cellWidthForOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat columnCount = (CGFloat)[self columnCountForOrientation:orientation];
    CGFloat cellSpacing = [self cellSpacingForOrientation:orientation];
    CGFloat deviceWidth = (UIInterfaceOrientationIsPortrait(orientation) ? CGRectGetWidth([UIScreen mainScreen].bounds) : CGRectGetHeight([UIScreen mainScreen].bounds));
    return floorf((deviceWidth - (columnCount + 1) * cellSpacing) / columnCount);
}

+ (UIEdgeInsets)cellMarginForOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat spacingSize = [self cellSpacingForOrientation:orientation];
    return UIEdgeInsetsMake(spacingSize, spacingSize, spacingSize, spacingSize);
}

+ (CGFloat)cellSpacingForOrientation:(UIInterfaceOrientation)orientation
{
    return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 14.0 : 10.0);
}

+ (NSInteger)columnCountForOrientation:(UIInterfaceOrientation)orientation
{
    return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (UIInterfaceOrientationIsPortrait(orientation) ? 2 : 3) : 1);
}

@end
