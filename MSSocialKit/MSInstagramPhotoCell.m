//
//  RSInstagramPhotoCell.m
//  MSSocialKit
//
//  Created by Devon Tivona on 2/18/13.
//  Copyright (c) 2013 Devon Tivona. All rights reserved.
//

#import "MSInstagramPhotoCell.h"
#import "MSInstagramPhoto.h"
#import "MSSocialKitManager.h"
#import "TTTTimeIntervalFormatter.h"
#import "UILabel+ApplyTextAttributes.h"
#import <QuartzCore/QuartzCore.h>
#import "NSObject+FirstAppearanceValue.h"

//#define LAYOUT_DEBUG

@implementation MSInstagramPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.backgroundColor = [UIColor whiteColor];
//        self.layer.shadowColor = [[UIColor blackColor] CGColor];
//        self.layer.shadowRadius = 2.0;
//        self.layer.shadowOpacity = 0.5;
//        self.layer.shadowOffset = CGSizeZero;
//        self.layer.masksToBounds = NO;
//        self.layer.borderColor = [[UIColor blackColor] CGColor];
//        self.layer.borderWidth = ([[UIScreen mainScreen] scale] == 2.0) ? 0.5 : 1.0;
//        self.layer.shouldRasterize = YES;
//        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];

        self.userLabel = [UILabel new];
        self.userLabel.backgroundColor = [UIColor clearColor];
        self.userLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.userLabel];
        
        self.timeLabel = [UILabel new];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.timeLabel];
        
        self.captionLabel = [UILabel new];
        self.captionLabel.backgroundColor = [UIColor clearColor];
        self.captionLabel.numberOfLines = 0.0;
        self.captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.captionLabel];
        
        self.userImageView = [UIImageView new];
        self.userImageView.backgroundColor = [UIColor lightGrayColor];
        self.userImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.userImageView];
        
        self.imageView = [UIImageView new];
        self.imageView.backgroundColor = [UIColor lightGrayColor];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.imageView];
        
#if defined(LAYOUT_DEBUG)
        self.contentView.backgroundColor = [UIColor blueColor];
        self.userLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.timeLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.captionLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.userImageView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
#endif
    }
    return self;
}

#pragma mark - MSSocialCell

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.userLabel applyTextAttributes:self.primaryTextAttributes];
    [self.timeLabel applyTextAttributes:self.secondaryTextAttributes];
    [self.captionLabel applyTextAttributes:self.contentTextAttributes];
    
    self.captionLabel.preferredMaxLayoutWidth = UIEdgeInsetsInsetRect(self.contentView.frame, self.padding).size.width;
    
    [self.contentView removeConstraints:self.contentView.constraints];
    
    NSDictionary *views = @{ @"user" : self.userLabel , @"time" : self.timeLabel , @"caption" : self.captionLabel, @"image" : self.imageView, @"profileImage" : self.userImageView };
    
    NSDictionary *metrics = @{
        @"paddingTop" : @(self.padding.top),
        @"paddingLeft" : @(self.padding.left),
        @"paddingBottom" : @(self.padding.bottom),
        @"paddingRight" : @(self.padding.right),
        @"contentMargin" : @(self.contentMargin),
        @"profileImageSizeWidth" : @(self.profileImageSize.width),
        @"profileImageSizeHeight" : @(self.profileImageSize.height),
    };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-paddingTop-[profileImage(==profileImageSizeHeight)]-contentMargin-[image]-contentMargin-[caption]" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-paddingLeft-[profileImage(==profileImageSizeWidth)]-contentMargin-[user(>=0)]-contentMargin-[time]-paddingRight-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-paddingLeft-[image]-paddingRight-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-paddingLeft-[caption]-paddingRight-|" options:0 metrics:metrics views:views]];
    
    // Center time and user vertically
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.userLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.userImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.userImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // Image view always has even heights and widths
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

#pragma - MSInstagramPhotoCell

- (void)setPhoto:(MSInstagramPhoto *)photo
{
    _photo = photo;

    // Instagram Photo
    [self.imageView setImageWithURL:[NSURL URLWithString:photo.standardResolutionURL] placeholderImage:nil];
    
    // Profile Photo
    [self.userImageView setImageWithURL:[NSURL URLWithString:photo.profilePictureURL] placeholderImage:nil];
    
    self.userLabel.text = photo.name ? photo.name : photo.username;
    self.captionLabel.text = photo.caption;
    
    // Setup time interval formatter
    static TTTTimeIntervalFormatter *timeIntervalFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        timeIntervalFormatter.usesAbbreviatedCalendarUnits = YES;
        timeIntervalFormatter.pastDeicticExpression = @"";
        timeIntervalFormatter.presentDeicticExpression = @"";
        [timeIntervalFormatter setLocale:[NSLocale currentLocale]];
    });
    self.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:photo.createdAt];
    
    [self setNeedsLayout];
}

+ (CGSize)cellSizeForCaption:(NSString *)caption orientation:(UIInterfaceOrientation)orientation;
{
    CGFloat width = [self cellWidthForOrientation:orientation];
    
    UIEdgeInsets padding = [[self firstAppearanceValueMatchingBlock:^id(id appearance) {
        return (!UIEdgeInsetsEqualToEdgeInsets([appearance padding], UIEdgeInsetsZero) ? [NSValue valueWithUIEdgeInsets:[appearance padding]] : nil);
    }] UIEdgeInsetsValue];
    
    CGFloat contentMargin = [[self firstAppearanceValueMatchingBlock:^id(id appearance) {
        return (([appearance contentMargin] != 0) ? @([appearance contentMargin]) : nil);
    }] floatValue];
    
    CGFloat profileImageHeight = [[self firstAppearanceValueMatchingBlock:^id(id appearance) {
        return (([appearance profileImageSize].height != 0) ? @([appearance profileImageSize].height) : nil);
    }] floatValue];
    
    UIFont *contentFont = [self firstAppearanceValueMatchingBlock:^id(id appearance) {
        return [appearance contentTextAttributes][UITextAttributeFont];
    }];
    
    CGSize captionSize;
    if (caption && ![caption isEqualToString:@""]) {
        CGSize maxTitleSize = CGSizeMake(width - (padding.left + padding.right), CGFLOAT_MAX);
        captionSize = [caption sizeWithFont:contentFont constrainedToSize:maxTitleSize];
    } else {
        captionSize = CGSizeZero;
    }
    
    CGFloat imageSize = (width - (padding.left + padding.right));
    
    CGFloat height = (padding.top + profileImageHeight + contentMargin + imageSize + contentMargin + captionSize.height + padding.bottom);
    return CGSizeMake(width, height);
}


@end
