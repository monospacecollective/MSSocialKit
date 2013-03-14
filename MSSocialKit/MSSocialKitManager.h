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

@property (strong, nonatomic) NSString *twitterComposeText;

@property (strong, nonatomic) NSString *twitterQuery;
@property (strong, nonatomic) NSString *instagramQuery;

@property (strong, nonatomic) UIColor *viewBackgroundColor;
@property (strong, nonatomic) UIColor *cellBackgroundColor;
@property (strong, nonatomic) UIColor *imageBorderColor;
@property (strong, nonatomic) UIColor *cellBorderColor;

@property (strong, nonatomic) NSDictionary *primaryTextAttributes;
@property (strong, nonatomic) NSDictionary *secondaryTextAttributes;
@property (strong, nonatomic) NSDictionary *contentTextAttributes;

+ (instancetype)sharedManager;

- (void)configureStorage;

@end
