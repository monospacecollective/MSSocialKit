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

@interface MSInstagramPhotoViewController () <NSFetchedResultsControllerDelegate, UICollectionViewDelegateWaterfallLayout>

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
    if (self) {
        self.cellClass = MSInstagramPhotoCell.class;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:self.cellClass forCellWithReuseIdentifier:RSInstagramPhotoCellReuseIdentifier];
    
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self configureLayoutForInterfaceOrientation:self.interfaceOrientation];
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
        layout.itemWidth = [MSInstagramPhotoCell cellWidthForOrientation:interfaceOrientation];
        layout.sectionInset = [MSInstagramPhotoCell cellMarginForOrientation:interfaceOrientation];
        layout.columnCount = [MSInstagramPhotoCell columnCountForOrientation:interfaceOrientation];
    } else {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        layout.sectionInset = [MSInstagramPhotoCell cellMarginForOrientation:interfaceOrientation];
        layout.minimumInteritemSpacing = [MSInstagramPhotoCell cellSpacingForOrientation:interfaceOrientation];
        layout.minimumLineSpacing = [MSInstagramPhotoCell cellSpacingForOrientation:interfaceOrientation];
    }
}

#pragma mark - RSInstagramViewController

- (void)addNew
{
    NSURL *instagramURL;
    if ([MSSocialKitManager sharedManager].defaultInstagramCaptionText) {
        instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://camera?caption=%@", RKPercentEscapedQueryStringFromStringWithEncoding([MSSocialKitManager sharedManager].defaultInstagramCaptionText, NSUTF8StringEncoding)]];
    } else {
        instagramURL = [NSURL URLWithString:@"instagram://camera"];
    }
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
    __weak typeof(self) weakSelf = self;
    RKObjectManager *objectManager = [[MSSocialKitManager sharedManager] instagramObjectManager];
    [objectManager getObjectsAtPath:path parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [weakSelf.refreshControl endRefreshing];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
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
    MSInstagramPhoto *instagramPhoto = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [MSInstagramPhotoCell cellSizeForCaption:instagramPhoto.caption orientation:self.interfaceOrientation];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSInstagramPhoto *instagramPhoto = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [MSInstagramPhotoCell cellSizeForCaption:instagramPhoto.caption orientation:self.interfaceOrientation].height;
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This device is not configured to view Instagram photos." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
    }
}

@end
