//
//  MSSocialCell.h
//  Pods
//
//  Created by Eric Horacek on 3/14/13.
//
//

#import <UIKit/UIKit.h>

@interface MSSocialCell : UICollectionViewCell

@property (nonatomic, assign) UIEdgeInsets padding UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat contentMargin UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize profileImageSize UI_APPEARANCE_SELECTOR;

@property (nonatomic, retain) NSString *backgroundViewClass UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) NSString *selectedBackgroundViewClass UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) NSDictionary *primaryTextAttributes UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) NSDictionary *secondaryTextAttributes UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) NSDictionary *contentTextAttributes UI_APPEARANCE_SELECTOR;

+ (void)applyDefaultAppearance;

+ (CGFloat)cellWidthForOrientation:(UIInterfaceOrientation)orientation;
+ (UIEdgeInsets)cellMarginForOrientation:(UIInterfaceOrientation)orientation;
+ (CGFloat)cellSpacingForOrientation:(UIInterfaceOrientation)orientation;
+ (NSInteger)columnCountForOrientation:(UIInterfaceOrientation)orientation;

@end
