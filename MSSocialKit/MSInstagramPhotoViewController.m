//
//  RSInstagramViewController.m
//  MSSocialKit
//
//  Created by Devon Tivona on 2/18/13.
//  Copyright (c) 2013 Devon Tivona. All rights reserved.
//

#import "MSInstagramPhotoViewController.h"
#import "MSInstagramPhotoCell.h"
#import "MSInstagramPhoto.h"
#import "MSPlaceholderLabel.h"
#import "MSSocialKitManager.h"

#import <RestKit/RestKit.h>

NSString * const RSInstagramPhotoCellReuseIdentifier = @"RSInstagramPhotoCellReuseIdentifier";

@interface MSInstagramPhotoViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIView *placeholderLabel;

- (void)reloadData;
- (void)configureLayoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

@implementation MSInstagramPhotoViewController

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
    
    [self.collectionView registerClass:MSInstagramPhotoCell.class forCellWithReuseIdentifier:RSInstagramPhotoCellReuseIdentifier];
    self.collectionView.backgroundColor = [MSSocialKitManager sharedManager].viewBackgroundColor;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.collectionView.delegate = self;
    }
    
    // Setup fetch request delegate
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"InstagramPhoto"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[[MSSocialKitManager sharedManager] instagramObjectManager].managedObjectStore.mainQueueManagedObjectContext
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
        self.placeholderLabel = [MSSocialKitManager sharedManager].instagramPlaceholderView;
    } else {
        MSPlaceholderLabel *placeholderLabel = [MSPlaceholderLabel new];
        placeholderLabel.frame = self.collectionView.bounds;
        placeholderLabel.text = @"No Photos Available";
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
        UICollectionViewWaterfallLayout *flowLayout = (UICollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
        flowLayout.itemWidth = [MSInstagramPhotoCell cellWidthForInterfaceOrientation:interfaceOrientation];
        flowLayout.sectionInset = [MSInstagramPhotoCell cellMarginForInterfaceOrientation:interfaceOrientation];
        flowLayout.columnCount = [MSInstagramPhotoCell columnCountForInterfaceOrientation:interfaceOrientation];
    } else {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        layout.sectionInset = [MSInstagramPhotoCell cellMarginForInterfaceOrientation:interfaceOrientation];
        layout.minimumInteritemSpacing = [MSInstagramPhotoCell cellSpacingForInterfaceOrientation:interfaceOrientation];
        layout.minimumLineSpacing = [MSInstagramPhotoCell cellSpacingForInterfaceOrientation:interfaceOrientation];
    }
}

#pragma mark - RSInstagramViewController

- (void)addNew
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://camera"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This device does not have Instagram installed." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)reloadData {
    
    // Map params in to a NSDictionary
    NSDictionary *queryParams = @{ @"client_id" : @"ddcc557cf08847b38727f07eaeb382cd" };
    NSString *path = [NSString stringWithFormat:@"/v1/tags/%@/media/recent", [[MSSocialKitManager sharedManager] instagramQuery]];
    
    // Send request
    RKObjectManager *objectManager = [[MSSocialKitManager sharedManager] instagramObjectManager];
    [objectManager getObjectsAtPath:path parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.refreshControl endRefreshing];
        NSLog(@"Fetched Instagram photos %@", [mappingResult array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        NSLog(@"Instagram photo load failed with error: %@", error);
    }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.placeholderLabel.hidden = self.fetchedResultsController.fetchedObjects.count;
    [self.collectionView reloadData];
}

# pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
     return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (MSInstagramPhotoCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSInstagramPhotoCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:RSInstagramPhotoCellReuseIdentifier forIndexPath:indexPath];
    cell.photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return cell;
}

# pragma mark - UICollectionViewDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForItemAtIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self heightForItemAtIndexPath:indexPath];
    CGFloat width = [MSInstagramPhotoCell cellWidthForInterfaceOrientation:self.interfaceOrientation];
    return CGSizeMake(width, height);
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSInstagramPhoto *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CGSize captionSize = [photo.caption sizeWithFont:[UIFont systemFontOfSize:[MSInstagramPhotoCell fontSize]]
                                   constrainedToSize:CGSizeMake([MSInstagramPhotoCell instagramImageSizeForInterfaceOrientation:self.interfaceOrientation].width, 1000)];
    
    
    NSInteger paddingCount = captionSize.height ? 4 : 3;
    return captionSize.height +
           [MSInstagramPhotoCell instagramImageSizeForInterfaceOrientation:self.interfaceOrientation].height +
           [MSInstagramPhotoCell profileImageSizeForInterfaceOrientation:self.interfaceOrientation].height +
           [MSInstagramPhotoCell cellPaddingForInterfaceOrientation:self.interfaceOrientation] * paddingCount;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSInstagramPhoto *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://media?id=%@", photo.remoteID]];
    NSURL *instagramWebURL = [NSURL URLWithString:photo.link];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    } else if ([[UIApplication sharedApplication] canOpenURL:instagramWebURL]) {
        [[UIApplication sharedApplication] openURL:instagramWebURL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This device is not configured to view Instagram photos." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles: nil];
        [alert show];
    }
}

@end
