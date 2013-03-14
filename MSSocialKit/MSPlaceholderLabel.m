//
//  RSPlaceholderLabel.m
//  MSSocialKit
//
//  Created by Devon Tivona on 2/26/13.
//  Copyright (c) 2013 Devon Tivona. All rights reserved.
//

#import "MSPlaceholderLabel.h"
#import "FXLabel.h"
#import <QuartzCore/QuartzCore.h>
#import <UIColor-Utilities/UIColor+Expanded.h>

@interface MSPlaceholderLabel  ()

@property (nonatomic, strong) FXLabel *textLabel;
@property (nonatomic, strong) FXLabel *iconLabel;

@end

@implementation MSPlaceholderLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.iconLabel = [FXLabel new];
        
        self.iconLabel.textAlignment = NSTextAlignmentCenter;
        self.iconLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        self.iconLabel.font = [[RSStyleManager sharedManager] symbolSetFontOfSize:80];
        self.iconLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        self.iconLabel.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.8].CGColor;
        self.iconLabel.backgroundColor = [UIColor clearColor];
        self.iconLabel.textColor = [UIColor colorWithHexString:@"AAAAAA"];
        self.iconLabel.backgroundColor = [UIColor clearColor];
        self.iconLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        self.iconLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        self.iconLabel.shadowBlur = 0.0;
        self.iconLabel.innerShadowColor = [UIColor colorWithHexString:@"111111"];
        self.iconLabel.innerShadowOffset = CGSizeMake(0.0, 1.0);
        self.iconLabel.textAlignment = NSTextAlignmentCenter;
        self.iconLabel.layer.masksToBounds = NO;
        self.iconLabel.text =  @"\U000026A0";
        [self addSubview:self.iconLabel];
        
        self.textLabel = [FXLabel new];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.textLabel.font = [UIFont boldSystemFontOfSize:20];
        self.textLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        self.textLabel.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.8].CGColor;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor colorWithHexString:@"AAAAAA"];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        self.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        self.textLabel.shadowBlur = 0.0;
        self.textLabel.innerShadowColor = [UIColor colorWithHexString:@"111111"];
        self.textLabel.innerShadowOffset = CGSizeMake(0.0, 1.0);
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.layer.masksToBounds = NO;
        self.textLabel.text = @"Not Available";
        [self addSubview:self.textLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.iconLabel sizeToFit];
    [self.textLabel sizeToFit];
    
    CGFloat padding = 0.01;
    CGFloat height = self.iconLabel.frame.size.height + self.textLabel.frame.size.height + self.frame.size.height * padding;
    
    CGFloat y = self.frame.size.height/2.0 - height/2.0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        y *= 0.7;
    }
    
    CGRect frame = CGRectMake(0, y, self.frame.size.width, self.iconLabel.frame.size.height);
    self.iconLabel.frame = frame;
    frame.origin.y += frame.size.height + self.frame.size.height * padding;
    frame.size.height = self.textLabel.frame.size.height;
    self.textLabel.frame = frame;
    
}


- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
}

@end