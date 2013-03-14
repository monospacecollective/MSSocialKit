//
//  RSCommunityViewController.m
//  MSSocialKit
//
//  Created by Devon Tivona on 2/18/13.
//  Copyright (c) 2013 Devon Tivona. All rights reserved.
//

#import "MSSocialKitViewController.h"
#import "MSTweetsViewController.h"
#import "MSInstagramPhotoViewController.h"
#import "SVSegmentedControl.h"
#import "MSSocialKitManager.h"

typedef NS_ENUM(NSUInteger, RSCommunityViewControllerType) {
    RSCommunityViewControllerTypeTwitter,
    RSCommunityViewControllerTypeInstagram,
    RSCommunityViewControllerTypeCount
};

@interface MSSocialKitViewController ()

- (void)setChildViewController;

@property (nonatomic, strong) NSDictionary *childTitles;
@property (nonatomic, strong) NSDictionary *childClasses;

@end

@implementation MSSocialKitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.childTitles = @{
        @(RSCommunityViewControllerTypeTwitter) : @"Community",
        @(RSCommunityViewControllerTypeInstagram) : @"Schedule",
        };
        self.childClasses = @{
        @(RSCommunityViewControllerTypeTwitter) : MSTweetsViewController.class,
        @(RSCommunityViewControllerTypeInstagram) : MSInstagramPhotoViewController.class,
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGFloat height, width;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        height = self.view.frame.size.width;
        width = self.view.frame.size.height;
    } else {
        height = self.view.frame.size.height;
        width = self.view.frame.size.width;
    }
    
    self.view.frame = CGRectMake(0, 0, width, height);
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.view addSubview:self.containerView];
    self.containerView.backgroundColor = [UIColor redColor];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // Configure segmented control
    self.segmentedControl = [[SVSegmentedControl alloc] initWithSectionTitles:@[@"Twitter", @"Instagram"]];
    self.segmentedControl.titleEdgeInsets = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0);
    self.segmentedControl.thumbEdgeInset = UIEdgeInsetsMake(2.0, 3.0, 3.0, 3.0);
    self.segmentedControl.height = 30.0;
    self.segmentedControl.backgroundImage = [[UIImage imageNamed:@"MSNavigationButtonSquare"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    self.segmentedControl.cornerRadius = 5.0;
    self.segmentedControl.textColor = [UIColor whiteColor];
    self.segmentedControl.font = [UIFont boldSystemFontOfSize:12.0];
    self.segmentedControl.thumb.tintColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.segmentedControl.thumb.textColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.segmentedControl.thumb.textShadowColor = [UIColor whiteColor];
    self.segmentedControl.thumb.textShadowOffset = CGSizeMake(0.0, 1.0);
    [self.segmentedControl addTarget:self action:@selector(setChildViewController) forControlEvents:UIControlEventValueChanged];
    
    NSArray *toolbarItems = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl],
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
    ];
    
    self.toolbarItems = toolbarItems;
    [self.navigationController setToolbarHidden:NO];

    // Create an add button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIEdgeInsets buttonBackgroundImageCapInsets = UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0);
    UIImage *backgroundImage = [[UIImage imageNamed:@"MSNavigationButton"] resizableImageWithCapInsets:buttonBackgroundImageCapInsets];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    UIImage *highlightedBackgroundImage = [[UIImage imageNamed:@"MSNavigationButtonPressed"] resizableImageWithCapInsets:buttonBackgroundImageCapInsets];
    [button setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button setTitle:@"Compose" forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(1.0, 11.0, 0.0, 11.0);
    [button sizeToFit];
    
    [button addTarget:self action:@selector(addNewButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    [self setChildViewController];
}

- (void)addNewButtonPressed
{
    [self.currentChildViewController addNew];
}

- (void)setChildViewController
{
    RSCommunityViewControllerType communityViewControllerType = self.segmentedControl.selectedIndex;
    
    Class childViewControllerClass = self.childClasses[@(communityViewControllerType)];
    NSParameterAssert([childViewControllerClass isSubclassOfClass:UIViewController.class]);
    UIViewController *childViewController = (UIViewController *)[[childViewControllerClass alloc] init];
    
    [self.currentChildViewController willMoveToParentViewController:nil];
    [self addChildViewController:childViewController];
    childViewController.view.frame = CGRectMake(0.0, 0.0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    
    CGFloat duration = 0.8;
    
    if (self.currentChildViewController == nil) {
        [self.containerView addSubview:childViewController.view];
        [childViewController didMoveToParentViewController:self];
        self.currentChildViewController = (UIViewController<MSSocialChildViewController> *)childViewController;
    } else {
        [UIView transitionFromView:self.currentChildViewController.view
                            toView:childViewController.view
                          duration:duration
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL finished) {
                            [self.currentChildViewController removeFromParentViewController];
                            [childViewController didMoveToParentViewController:self];
                            self.currentChildViewController = (UIViewController<MSSocialChildViewController> *)childViewController;
                        }];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
