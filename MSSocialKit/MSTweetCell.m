//
//  RSTweetCell.m
//  RHSMUN
//
//  Created by Devon Tivona on 11/12/12.
//  Copyright (c) 2012 Devon Tivona. All rights reserved.
//

#import "MSTweetCell.h"
#import "MSTweet.h"
#import "MSSocialKitManager.h"
#import "AFNetworking.h"
#import "TTTTimeIntervalFormatter.h"
#import "UILabel+ApplyTextAttributes.h"
#import "NSObject+FirstAppearanceValue.h"
#import <QuartzCore/QuartzCore.h>

//#define LAYOUT_DEBUG

@implementation MSTweetCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.layer.shadowColor = [[UIColor blackColor] CGColor];
//        self.layer.shadowRadius = 2.0;
//        self.layer.shadowOpacity = 0.5;
//        self.layer.shadowOffset = CGSizeZero;
//        self.layer.masksToBounds = NO;
//        self.layer.borderColor = [[UIColor blackColor] CGColor];
//        self.layer.borderWidth = ([[UIScreen mainScreen] scale] == 2.0) ? 0.5 : 1.0;
//        self.layer.shouldRasterize = YES;
//        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        self.user = [UILabel new];
        self.user.backgroundColor = [UIColor clearColor];
        self.user.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.user];
        
        self.time = [UILabel new];
        self.time.backgroundColor = [UIColor clearColor];
        self.time.textAlignment = NSTextAlignmentRight;
        self.time.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.time];
        
        self.content = [UILabel new];
        self.content.backgroundColor = [UIColor clearColor];
        self.content.translatesAutoresizingMaskIntoConstraints = NO;
        self.content.numberOfLines = 0;
        [self.contentView addSubview:self.content];
        
        self.userImageView = [UIImageView new];
        self.userImageView.backgroundColor = [UIColor lightGrayColor];
        self.userImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.userImageView];
        
#if defined(LAYOUT_DEBUG)
        self.contentView.backgroundColor = [UIColor blueColor];
        self.user.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.time.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.content.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.userImageView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
#endif
    }
    return self;
}

#pragma mark - MSSocialCell

- (void)updateConstraints
{   
    [super updateConstraints];
    
    [self.user applyTextAttributes:self.primaryTextAttributes];
    [self.time applyTextAttributes:self.secondaryTextAttributes];
    [self.content applyTextAttributes:self.contentTextAttributes];
    
    self.content.preferredMaxLayoutWidth = UIEdgeInsetsInsetRect(self.contentView.frame, self.padding).size.width;
    
    [self.contentView removeConstraints:self.contentView.constraints];
    
    NSDictionary *views = @{ @"user" : self.user , @"time" : self.time , @"tweet" : self.content, @"profileImage" : self.userImageView };
    NSDictionary *metrics = @{
        @"paddingTop" : @(self.padding.top),
        @"paddingLeft" : @(self.padding.left),
        @"paddingBottom" : @(self.padding.bottom),
        @"paddingRight" : @(self.padding.right),
        @"contentMargin" : @(self.contentMargin),
        @"profileImageSizeWidth" : @(self.profileImageSize.width),
        @"profileImageSizeHeight" : @(self.profileImageSize.height)
    };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-paddingTop-[profileImage(==profileImageSizeHeight)]-contentMargin-[tweet]-paddingBottom-|" options:0 metrics:metrics views:views]];
    
    // Center time and user vertically
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.user attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.userImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.time attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.userImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-paddingLeft-[profileImage(==profileImageSizeWidth)]-contentMargin-[user(>=0)]-contentMargin-[time]-paddingRight-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-paddingLeft-[tweet]-paddingRight-|" options:0 metrics:metrics views:views]];
}

#pragma - MSTweetCell

- (void)setTweet:(MSTweet *)tweet
{
    _tweet = tweet;
    
    if ([tweet.userName isEqualToString:@""]) {
        self.user.text = tweet.userHandle;
    } else {
        self.user.text = tweet.userName;
    }
    
    self.content.text = tweet.text;
    
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
    self.time.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:tweet.createdAt];
    
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=bigger", tweet.userHandle]];
    [self.userImageView setImageWithURL:imageURL placeholderImage:nil];
    
    [self setNeedsUpdateConstraints];
}

+ (CGSize)cellSizeForTweet:(NSString *)tweet orientation:(UIInterfaceOrientation)orientation;
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
    
    CGSize tweetSize;
    if (tweet && ![tweet isEqualToString:@""]) {
        CGSize maxTitleSize = CGSizeMake(width - (padding.left + padding.right), CGFLOAT_MAX);
        tweetSize = [tweet sizeWithFont:contentFont constrainedToSize:maxTitleSize];
    } else {
        tweetSize = CGSizeZero;
    }
    
    CGFloat height = (padding.top + profileImageHeight + contentMargin + tweetSize.height + padding.bottom);
    return CGSizeMake(width, height);
}

@end
