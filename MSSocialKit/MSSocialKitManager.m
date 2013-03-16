//
//  MSSocialKitStorageManager.m
//  Pods
//
//  Created by Devon Tivona on 3/13/13.
//
//

#import "MSSocialKitManager.h"
#import "MSSocialCell.h"

static MSSocialKitManager *singletonInstance = nil;

@implementation MSSocialKitManager

+ (instancetype)sharedManager
{
    if (!singletonInstance) {
        singletonInstance = [[[self class] alloc] init];
    }
    return singletonInstance;
}

- (void)configureStorage
{
    // Sets the activity indicator to spin when a request is happening
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Initialize managed object store
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    // Twitter Object Manager
    self.twitterObjectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://search.twitter.com/"]];
    self.twitterObjectManager.managedObjectStore = managedObjectStore;
    
    NSEntityDescription *tweetEntity = [[managedObjectStore.managedObjectModel entitiesByName] objectForKey:@"Tweet"];
    tweetEntity.managedObjectClassName = @"MSTweet";
    
    RKEntityMapping *tweetMapping = [[RKEntityMapping alloc] initWithEntity:tweetEntity];
    tweetMapping.identificationAttributes = @[@"remoteID"];
    [tweetMapping addAttributeMappingsFromDictionary: @{
     @"from_user_name": @"userName",
     @"from_user": @"userHandle",
     @"created_at": @"createdAt",
     @"profile_image_url": @"profileImageURL",
     @"text": @"text",
     @"id_str": @"remoteID"
     }];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eee, dd MMM yyyy HH:mm:ss ZZZZ"]; // Tue, 10 Jul 2012 15:50:04 +0000
    tweetMapping.dateFormatters = @[dateFormatter];
    
    RKResponseDescriptor *tweetSearchResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tweetMapping
                                                                                                  pathPattern:nil
                                                                                                      keyPath:@"results"
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.twitterObjectManager addResponseDescriptor:tweetSearchResponseDescriptor];
    
    // Instagram Object Manager
    self.instagramObjectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"https://api.instagram.com/"]];
    self.instagramObjectManager.managedObjectStore = managedObjectStore;
    
    NSEntityDescription *instagramPhotoEntity = [[managedObjectStore.managedObjectModel entitiesByName] objectForKey:@"InstagramPhoto"];
    instagramPhotoEntity.managedObjectClassName = @"MSInstagramPhoto";
    
    RKEntityMapping *instagramPhotoMapping = [[RKEntityMapping alloc] initWithEntity:instagramPhotoEntity];
    instagramPhotoMapping.identificationAttributes = @[@"remoteID"];
    [instagramPhotoMapping addAttributeMappingsFromDictionary: @{
     @"link": @"link",
     @"images.thumbnail.url": @"thumbnailURL",
     @"images.low_resolution.url": @"lowResolutionURL",
     @"images.standard_resolution.url": @"standardResolutionURL",
     @"user.name": @"username",
     @"user.full_name": @"name",
     @"user.id": @"userID",
     @"user.profile_picture": @"profilePictureURL",
     @"caption.text": @"caption",
     @"id": @"remoteID",
     @"created_time": @"createdAt",
     }];
    
    RKResponseDescriptor *instagramPhotoSearchResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:instagramPhotoMapping
                                                                                                           pathPattern:nil
                                                                                                               keyPath:@"data"
                                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.instagramObjectManager addResponseDescriptor:instagramPhotoSearchResponseDescriptor];
    
    [managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"MSSocialKit.sqlite"];
    NSError *error;
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    [managedObjectStore createManagedObjectContexts];
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];

}

@end
