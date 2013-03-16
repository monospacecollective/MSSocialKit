//
//  RSTweetCell.h
//  RHSMUN
//
//  Created by Devon Tivona on 11/12/12.
//  Copyright (c) 2012 Devon Tivona. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSocialCell.h"

@class MSTweet;

@interface MSTweetCell : MSSocialCell

@property (strong, nonatomic) MSTweet *tweet;

@property (strong, nonatomic) UILabel *user;
@property (strong, nonatomic) UILabel *time;
@property (strong, nonatomic) UILabel *content;
@property (strong, nonatomic) UIImageView *userImageView;

+ (CGSize)cellSizeForTweet:(NSString *)tweet orientation:(UIInterfaceOrientation)orientation;

@end
