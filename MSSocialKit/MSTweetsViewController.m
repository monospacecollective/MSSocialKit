//
//  RSTweetsViewController.m
//  RHSMUN
//
//  Created by Devon Tivona on 11/12/12.
//  Copyright (c) 2012 Devon Tivona. All rights reserved.
//

#import "MSTweetsViewController.h"
#import "MSTweet.h"
#import "MSTweetCell.h"
#import "MSPlaceholderLabel.h"
#import "MSSocialKitManager.h"

#import <Social/Social.h>
#import "TTTTimeIntervalFormatter.h"
#import <QuartzCore/QuartzCore.h>
#import <RestKit/RestKit.h>

NSString * const RSTweetCellReuseIdentifier = @"RSTweetCellReuseIdentifier";

@interface MSTweetsViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIView *placeholderLabel;

- (void)reloadData;
- (void)configureLayoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

@implementation MSTweetsViewController

- (id)init
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UICollectionViewWaterfallLayout *layout = [[UICollectionViewWaterfallLayout alloc] init];
        layout.delegate = self;
        self = [super initWithCollectionViewLayout:layout];
    } else {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        self = [super initWithCollectionViewLayout:layout];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [MSSocialKitManager sharedManager].viewBackgroundColor;
    [self.collectionView registerClass:MSTweetCell.class forCellWithReuseIdentifier:RSTweetCellReuseIdentifier];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.collectionView.delegate = self;
    }
    
    // Setup fetch request delegate
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[[MSSocialKitManager sharedManager] twitterObjectManager].managedObjectStore.mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert2(fetchSuccessful, @"Unable to fetch %@, %@", fetchRequest.entityName, [error debugDescription]);
    
    // Configure refresh view controller
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [MSSocialKitManager sharedManager].cellBackgroundColor;
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    // Configure placeholder label
    if ([MSSocialKitManager sharedManager].twitterPlaceholderView) {
        self.placeholderLabel = [MSSocialKitManager sharedManager].twitterPlaceholderView;
    } else {
        MSPlaceholderLabel *placeholderLabel = [MSPlaceholderLabel new];
        placeholderLabel.frame = self.collectionView.bounds;
        placeholderLabel.text = @"No Tweets Available";
        self.placeholderLabel = placeholderLabel;
    }
    
    self.collectionView.backgroundView = self.placeholderLabel;
    [self.placeholderLabel setNeedsLayout];
    
    // Reload the data
    [self reloadData];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self configureLayoutForInterfaceOrientation:toInterfaceOrientation];
}

- (void)viewWillLayoutSubviews
{
    self.placeholderLabel.hidden = self.fetchedResultsController.fetchedObjects.count;
    [self configureLayoutForInterfaceOrientation:self.interfaceOrientation];
}

#pragma mark - RSTweetsViewController

- (void)configureLayoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UICollectionViewWaterfallLayout *layout = (UICollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
        layout.itemWidth = [MSTweetCell cellWidthForInterfaceOrientation:interfaceOrientation];
        layout.sectionInset = [MSTweetCell cellMarginForInterfaceOrientation:interfaceOrientation];
        layout.columnCount = [MSTweetCell columnCountForInterfaceOrientation:interfaceOrientation];
    } else {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        layout.sectionInset = [MSTweetCell cellMarginForInterfaceOrientation:interfaceOrientation];
        layout.minimumInteritemSpacing = [MSTweetCell cellSpacingForInterfaceOrientation:interfaceOrientation];
        layout.minimumLineSpacing = [MSTweetCell cellSpacingForInterfaceOrientation:interfaceOrientation];
    }
}

- (void)addNew
{    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:[[MSSocialKitManager sharedManager] twitterComposeText]];
        [self presentViewController:composeViewController animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This device is not configured to post to Twitter." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)reloadData {
    
    // Set up search params
    NSString *q = [[MSSocialKitManager sharedManager] twitterQuery];
    NSString *rpp = @"100";
    NSString *withTwitterUserId = @"true";
    NSString *resultType = @"recent";
    
    // Map params in to a NSDictionary
    NSDictionary *queryParams;
    queryParams = [NSDictionary dictionaryWithObjectsAndKeys:q, @"q", rpp, @"rpp", withTwitterUserId, @"with_twitter_user_id", resultType, @"result_type", nil];
    
    // Send request
    RKObjectManager *objectManager = [[MSSocialKitManager sharedManager] twitterObjectManager];
    [objectManager getObjectsAtPath:@"/search.json" parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.refreshControl endRefreshing];
        NSLog(@"Fetched tweets %@", [mappingResult array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        NSLog(@"Tweet load failed with error: %@", error);
    }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.placeholderLabel.hidden = self.fetchedResultsController.fetchedObjects.count;
    [self.collectionView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (MSTweetCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSTweetCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:RSTweetCellReuseIdentifier forIndexPath:indexPath];
    cell.tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForItemAtIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self heightForItemAtIndexPath:indexPath];
    CGFloat width = [MSTweetCell cellWidthForInterfaceOrientation:self.interfaceOrientation];
    return CGSizeMake(width, height);
}
              
- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
  MSTweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  CGFloat width = [MSTweetCell cellWidthForInterfaceOrientation:self.interfaceOrientation] - [MSTweetCell cellPaddingForInterfaceOrientation:self.interfaceOrientation] * 2;
  CGFloat fontSize = [MSTweetCell tweetFontSize];
  
  CGSize textSize = [tweet.text sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, 1000)];
  CGFloat height = textSize.height +
  [MSTweetCell cellPaddingForInterfaceOrientation:self.interfaceOrientation] * 3 +
  [MSTweetCell profileImageSizeForInterfaceOrientation:self.interfaceOrientation].height;
  
  return height;
}

#pragma mark - UITableViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSTweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIApplication *application = [UIApplication sharedApplication];
    
    NSString *path = [NSString stringWithFormat:@"twitter://status?id=%@", tweet.remoteID];
    NSURL *URL = [NSURL URLWithString:path];
    
    if ([application canOpenURL:URL]) {
        [application openURL:URL];
    }
}

@end
