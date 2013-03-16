//
//  MSSocialKitStorageManager.h
//  Pods
//
//  Created by Devon Tivona on 3/13/13.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface MSSocialKitManager : NSObject

@property (strong, nonatomic) RKObjectManager *twitterObjectManager;
@property (strong, nonatomic) RKObjectManager *instagramObjectManager;

@property (strong, nonatomic) NSString *defaultTwitterComposeText;
@property (strong, nonatomic) NSString *defaultInstagramCaptionText;

@property (strong, nonatomic) NSString *twitterQuery;
@property (strong, nonatomic) NSString *instagramQuery;

@property (strong, nonatomic) UIView *twitterPlaceholderView;
@property (strong, nonatomic) UIView *instagramPlaceholderView;

+ (instancetype)sharedManager;

- (void)configureStorage;

@end
