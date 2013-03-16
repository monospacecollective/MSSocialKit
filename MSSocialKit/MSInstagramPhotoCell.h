//
//  RSInstagramPhotoCell.h
//  MSSocialKit
//
//  Created by Devon Tivona on 2/18/13.
//  Copyright (c) 2013 Devon Tivona. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSocialCell.h"

@class MSInstagramPhoto;

@interface MSInstagramPhotoCell : MSSocialCell

@property (strong, nonatomic) MSInstagramPhoto *photo;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *userImageView;
@property (strong, nonatomic) UILabel *userLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *captionLabel;

+ (CGSize)cellSizeForCaption:(NSString *)caption orientation:(UIInterfaceOrientation)orientation;

@end
