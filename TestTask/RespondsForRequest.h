//
//  RespondsForRequest.h
//  TestTask
//
//  Created by Admin on 26.07.15.
//  Copyright (c) 2015 ArtemyevSergey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Requests;

@interface RespondsForRequest : NSManagedObject

@property (nonatomic, retain) NSNumber * centerLatitude;
@property (nonatomic, retain) NSNumber * centerLongitude;
@property (nonatomic, retain) NSString * formattedAddress;
@property (nonatomic, retain) NSNumber * northEastLatitude;
@property (nonatomic, retain) NSNumber * northEastLongitude;
@property (nonatomic, retain) NSNumber * responseNumber;
@property (nonatomic, retain) NSNumber * southWestLatitude;
@property (nonatomic, retain) NSNumber * southWestLongitude;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) Requests *request;

@end
