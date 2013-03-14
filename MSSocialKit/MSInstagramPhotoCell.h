//
//  RSInstagramPhotoCell.h
//  IMUNA
//
//  Created by Devon Tivona on 2/18/13.
//  Copyright (c) 2013 Devon Tivona. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSInstagramPhoto;

@interface MSInstagramPhotoCell : UICollectionViewCell

@property (nonatomic, strong) MSInstagramPhoto *photo;


+ (CGFloat)cellWidthForInterfaceOrientation:(UIInterfaceOrientation)orientation;
+ (CGFloat)cellSpacingForInterfaceOrientation:(UIInterfaceOrientation)orientation;
+ (CGFloat)cellPaddingForInterfaceOrientation:(UIInterfaceOrientation)orientation;

+ (NSInteger)columnCountForInterfaceOrientation:(UIInterfaceOrientation)orientation;

+ (UIEdgeInsets)cellMarginForInterfaceOrientation:(UIInterfaceOrientation)orientation;

+ (CGSize)profileImageSizeForInterfaceOrientation:(UIInterfaceOrientation)orientation;
+ (CGSize)instagramImageSizeForInterfaceOrientation:(UIInterfaceOrientation)orientation;

+ (CGFloat)fontSize;

@end
 