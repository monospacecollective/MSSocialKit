//
//  RSCommunityViewController.h
//  MSSocialKit
//
//  Created by Devon Tivona on 2/18/13.
//  Copyright (c) 2013 Devon Tivona. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVSegmentedControl.h"

@protocol MSSocialChildViewController;

@interface MSSocialKitViewController : UIViewController

@property (strong, nonatomic) SVSegmentedControl *segmentedControl;
@property (strong, nonatomic) UIViewController <MSSocialChildViewController> *currentChildViewController;
@property (strong, nonatomic) UIView *containerView;

- (void)addNewButtonPressed;
- (void)setChildViewController;

@end

@protocol MSSocialChildViewController

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) Class cellClass;

- (void)addNew;

@end
