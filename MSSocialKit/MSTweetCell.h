//
//  RSTweetCell.h
//  RHSMUN
//
//  Created by Devon Tivona on 11/12/12.
//  Copyright (c) 2012 Devon Tivona. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSTweet;

@interface MSTweetCell : UICollectionViewCell

@property (strong, nonatomic) MSTweet *tweet;

+ (CGFloat)cellWidthForInterfaceOrientation:(UIInterfaceOrientation)orientation;
+ (CGFloat)cellSpacingForInterfaceOrientation:(UIInterfaceOrientation)orientation;
+ (CGFloat)cellPaddingForInterfaceOrientation:(UIInterfaceOrientation)orientation;

+ (NSInteger)columnCountForInterfaceOrientation:(UIInterfaceOrientation)orientation;

+ (UIEdgeInsets)cellMarginForInterfaceOrientation:(UIInterfaceOrientation)orientation;

+ (CGSize)profileImageSizeForInterfaceOrientation:(UIInterfaceOrientation)orientation;

+ (CGFloat)tweetFontSize;

@end
