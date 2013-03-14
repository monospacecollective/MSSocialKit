//
//  RSTweet.h
//  MSSocialKit
//
//  Created by Devon Tivona on 2/18/13.
//  Copyright (c) 2013 Devon Tivona. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MSTweet : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userHandle;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * profileImageURL;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * remoteID;

@end
