//
//  RSInstagramViewController.h
//  MSSocialKit
//
//  Created by Devon Tivona on 2/18/13.
//  Copyright (c) 2013 Devon Tivona. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSocialKitViewController.h"
#import "UICollectionViewWaterfallLayout.h"

@interface MSInstagramPhotoViewController : UICollectionViewController <MSSocialChildViewController>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) Class cellClass;

@end
