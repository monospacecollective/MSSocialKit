//
//  RSInstagramPhotoCell.m
//  IMUNA
//
//  Created by Devon Tivona on 2/18/13.
//  Copyright (c) 2013 Devon Tivona. All rights reserved.
//

#import "MSInstagramPhotoCell.h"
#import "MSInstagramPhoto.h"
#import "MSSocialKitManager.h"

#import "TTTTimeIntervalFormatter.h"
#import "UILabel+ApplyTextAttributes.h"

#import <RestKit/RestKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MSInstagramPhotoCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *userImageView;
@property (strong, nonatomic) UILabel *userLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *captionLabel;

@end

@implementation MSInstagramPhotoCell

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
        
        self.captionLabel = [UILabel new];
        self.captionLabel.backgroundColor = [UIColor clearColor];
        [self.captionLabel applyTextAttributes:[[MSSocialKitManager sharedManager] contentTextAttributes]];
        self.captionLabel.numberOfLines = 0.0;
        [self addSubview:self.captionLabel];
        
        self.userImageView = [UIImageView new];
        self.userImageView.backgroundColor = [UIColor lightGrayColor];
        self.userImageView.layer.borderColor = [[MSSocialKitManager sharedManager] imageBorderColor].CGColor;
        self.userImageView.layer.borderWidth = ([[UIScreen mainScreen] scale] == 2.0) ? 0.5 : 1.0;
        [self addSubview:self.userImageView];
        
        self.imageView = [UIImageView new];
        self.imageView.backgroundColor = [UIColor lightGrayColor];
        self.imageView.layer.borderColor = [[MSSocialKitManager sharedManager] imageBorderColor].CGColor;
        self.imageView.layer.borderWidth = ([[UIScreen mainScreen] scale] == 2.0) ? 0.5 : 1.0;
        [self addSubview:self.imageView];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    frame.size.width = [MSInstagramPhotoCell cellWidthForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    self.frame = frame;
    
    CGFloat padding = [MSInstagramPhotoCell cellPaddingForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    CGSize imageSize = [MSInstagramPhotoCell profileImageSizeForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
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
    frame.size.width = [MSInstagramPhotoCell instagramImageSizeForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]].width;
    frame.size.height = [MSInstagramPhotoCell instagramImageSizeForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]].height;
    
    self.imageView.frame = frame;
    
    frame.origin.y += padding + frame.size.height;
    frame.size.height = [self.captionLabel.text sizeWithFont:[UIFont systemFontOfSize:[MSInstagramPhotoCell fontSize]]
                                         constrainedToSize:CGSizeMake(frame.size.width, 1000)].height;
    self.captionLabel.frame = frame;
    [self.captionLabel sizeToFit];
}


- (void)setPhoto:(MSInstagramPhoto *)photo
{
    _photo = photo;
    
    // Instagram Photo
    NSURL *imageURL = [NSURL URLWithString:photo.standardResolutionURL];
    NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:imageURL];
    [imageRequest setHTTPShouldHandleCookies:NO];
    [imageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    __weak typeof(self) weakSelf = self;
    [self.imageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.imageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    // Profile Photo
    NSURL *profileURL = [NSURL URLWithString:photo.profilePictureURL];
    NSMutableURLRequest *profileRequest = [NSMutableURLRequest requestWithURL:profileURL];
    [profileRequest setHTTPShouldHandleCookies:NO];
    [profileRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self.userImageView setImageWithURLRequest:profileRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.userImageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    self.userLabel.text = photo.name ? photo.name : photo.username;
    self.captionLabel.text = photo.caption;
    
    CGFloat captionVerticalOrigin;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        captionVerticalOrigin = 306 + 42 + 7 + 7;
    } else {
        captionVerticalOrigin = 306 + 42 + 7;
    }
    
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
    
    NSDate *now = [[NSDate alloc] init];
    self.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:now toDate:photo.createdAt];
    
    [self layoutSubviews];
}

# pragma mark - Class Methods

+ (CGFloat)cellWidthForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat columnCount = (CGFloat)[MSInstagramPhotoCell columnCountForInterfaceOrientation:orientation];
    CGFloat cellSpacing = [MSInstagramPhotoCell cellSpacingForInterfaceOrientation:orientation];
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
        return CGSizeMake(40.0, 40.0);
    }
}

+ (CGSize)instagramImageSizeForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat imageWidth = [MSInstagramPhotoCell cellWidthForInterfaceOrientation:orientation] -
                         [MSInstagramPhotoCell cellPaddingForInterfaceOrientation:orientation] * 2;
    return CGSizeMake(imageWidth, imageWidth);
}

+ (CGFloat)fontSize
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
