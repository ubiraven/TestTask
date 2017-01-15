//
//  CoreDataHelper.h
//  Laba7
//
//  Created by Admin on 23.03.15.
//  Copyright (c) 2015 Sergey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

+(id)insertManagedObjectWith:(NSString*)className in:(NSManagedObjectContext*)managedObjectContext;
+(NSArray*)fetchEntitiesWith:(NSString*)className in:(NSManagedObjectContext*)managedObjectContext with:(NSPredicate*)predicate;

@end
