//
//  RSInstagramPhoto.h
//  IMUNA
//
//  Created by Devon Tivona on 2/19/13.
//  Copyright (c) 2013 Devon Tivona. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MSInstagramPhoto : NSManagedObject

@property (nonatomic, retain) NSString * lowResolutionURL;
@property (nonatomic, retain) NSString * remoteID;
@property (nonatomic, retain) NSString * standardResolutionURL;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * profilePictureURL;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSDate * createdAt;

@end
