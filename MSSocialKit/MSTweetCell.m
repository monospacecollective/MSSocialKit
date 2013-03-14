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

#import <QuartzCore/QuartzCore.h>

@interface MSTweetCell ()

@property (strong, nonatomic) UILabel *userLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *tweetLabel;
@property (strong, nonatomic) UIImageView *userImageView;

@end

@implementation MSTweetCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [[MSSocialKitManager sharedManager] cellBackgroundColor];
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = 2.0;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.masksToBounds = NO;
        self.layer.borderColor = [[MSSocialKitManager sharedManager] cellBorderColor].CGColor;
        self.layer.borderWidth = ([[UIScreen mainScreen] scale] == 2.0) ? 0.5 : 1.0;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
            
        self.userLabel = [UILabel new];
        self.userLabel.backgroundColor = [UIColor clearColor];
        [self.userLabel applyTextAttributes:[[MSSocialKitManager sharedManager] primaryTextAttributes]];
        [self addSubview:self.userLabel];
        
        self.timeLabel = [UILabel new];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        [self.timeLabel applyTextAttributes:[[MSSocialKitManager sharedManager] secondaryTextAttributes]];    
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.timeLabel];
        
        self.tweetLabel = [UILabel new];
        self.tweetLabel.backgroundColor = [UIColor clearColor];
        [self.tweetLabel applyTextAttributes:[[MSSocialKitManager sharedManager] contentTextAttributes]];
        self.tweetLabel.numberOfLines = 0.0;
        [self addSubview:self.tweetLabel];
        
        self.userImageView = [UIImageView new];
        self.userImageView.backgroundColor = [UIColor lightGrayColor];
        self.userImageView.layer.borderColor = [[MSSocialKitManager sharedManager] imageBorderColor].CGColor;
        self.userImageView.layer.borderWidth = ([[UIScreen mainScreen] scale] == 2.0) ? 0.5 : 1.0;
        [self addSubview:self.userImageView];
    
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    frame.size.width = [MSTweetCell cellWidthForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    self.frame = frame;
    
    CGFloat padding = [MSTweetCell cellPaddingForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    CGSize imageSize = [MSTweetCell profileImageSizeForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    self.userImageView.frame = CGRectMake(padding, padding, imageSize.width, imageSize.height);
    
    [self.userLabel sizeToFit];
    frame = self.userLabel.frame;
    frame.origin.x = padding + self.userImageView.frame.size.width + self.userImageView.frame.origin.x;
    frame.origin.y = padding;
    frame.size.height = imageSize.height;
    self.userLabel.frame = frame;
    
    [self.timeLabel sizeToFit];
    frame.origin.x += padding + self.userLabel.frame.size.width;
    frame.size.width = self.frame.size.width - padding - frame.origin.x;
    self.timeLabel.frame = frame;
    
    frame.origin.x = padding;
    frame.origin.y = padding * 2 + imageSize.height;
    frame.size.width = self.frame.size.width - padding * 2;
    frame.size.height = [self.tweetLabel.text sizeWithFont:[UIFont systemFontOfSize:[MSTweetCell tweetFontSize]]
                                         constrainedToSize:CGSizeMake(frame.size.width, 1000)].height;
    self.tweetLabel.frame = frame;
    [self.tweetLabel sizeToFit];
}

- (void)setTweet:(MSTweet *)tweet
{
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
    
    if ([tweet.userName isEqualToString:@""]) {
        self.userLabel.text = tweet.userHandle;
    } else {
        self.userLabel.text = tweet.userName;
    }
    
    self.tweetLabel.text = tweet.text;
    
    // Format time label
    NSDate *now = [[NSDate alloc] init];
    self.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:now toDate:tweet.createdAt];
    
    // User image
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=bigger", tweet.userHandle]];
    NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:imageURL];
    [imageRequest setHTTPShouldHandleCookies:NO];
    [imageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    __weak typeof(self) weakSelf = self;
    [self.userImageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.userImageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    [self layoutSubviews];
}


# pragma mark - Class Methods

+ (CGFloat)cellWidthForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat columnCount = (CGFloat)[MSTweetCell columnCountForInterfaceOrientation:orientation];
    CGFloat cellSpacing = [MSTweetCell cellSpacingForInterfaceOrientation:orientation];
    CGFloat deviceWidth;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        deviceWidth = [[UIScreen mainScreen] bounds].size.height;
    } else {
        deviceWidth = [[UIScreen mainScreen] bounds].size.width;
    }
    
    return floorf((deviceWidth - (columnCount + 1) * cellSpacing)/columnCount);
}

+ (CGSize)profileImageSizeForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationIsLandscape(orientation) ? CGSizeMake(60.0, 60.0) : CGSizeMake(60.0, 60.0);
    } else {
        return CGSizeMake(50.0, 50.0);
    }
}

+ (CGFloat)tweetFontSize
{
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        return 16.0;
    } else {
        return 15.0;
    }
}

+ (CGFloat)cellPaddingForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 14.0;
    } else {
        return 10.0;
    }
}

+ (UIEdgeInsets)cellMarginForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat spacingSize = [self cellSpacingForInterfaceOrientation:orientation];
    return UIEdgeInsetsMake(spacingSize, spacingSize, spacingSize, spacingSize);
}

+ (CGFloat)cellSpacingForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        return 14.0;
    } else {
        return 10.0;
    }
}

+ (NSInteger)columnCountForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        return UIInterfaceOrientationIsLandscape(orientation) ? 3.0 : 2.0;
    } else {
        return 1.0;
    }
}

@end
