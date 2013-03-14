//
//  RSTweetsViewController.h
//  RHSMUN
//
//  Created by Devon Tivona on 11/12/12.
//  Copyright (c) 2012 Devon Tivona. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSocialKitViewController.h"
#import "UICollectionViewWaterfallLayout.h"

@interface MSTweetsViewController : UICollectionViewController <MSSocialChildViewController, UICollectionViewDataSource, UICollectionViewDelegateWaterfallLayout, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@end
