//
//  Requests.h
//  TestTask
//
//  Created by Admin on 25.07.15.
//  Copyright (c) 2015 ArtemyevSergey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RespondsForRequest;

@interface Requests : NSManagedObject

@property (nonatomic, retain) NSDate * dateOfRequest;
@property (nonatomic, retain) NSString * requestParameters;
@property (nonatomic, retain) NSSet *responds;
@end

@interface Requests (CoreDataGeneratedAccessors)

- (void)addRespondsObject:(RespondsForRequest *)value;
- (void)removeRespondsObject:(RespondsForRequest *)value;
- (void)addResponds:(NSSet *)values;
- (void)removeResponds:(NSSet *)values;

@end
