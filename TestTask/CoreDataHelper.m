//
//  CoreDataHelper.m
//  Laba7
//
//  Created by Admin on 23.03.15.
//  Copyright (c) 2015 Sergey. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

+(id)insertManagedObjectWith:(NSString*)className in:(NSManagedObjectContext*)managedObjectContext {
 
    NSManagedObject* managedObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:managedObjectContext];
    
    return managedObject;
}

+(NSArray*)fetchEntitiesWith:(NSString*)className in:(NSManagedObjectContext*)managedObjectContext with:(NSPredicate*)predicate{
    
    NSFetchRequest* fetchRequest = [NSFetchRequest new];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:className inManagedObjectContext:managedObjectContext];
    
    fetchRequest.entity = entityDescription;
    
    if (predicate != Nil) {
        fetchRequest.predicate = predicate;
    }
    
    fetchRequest.returnsObjectsAsFaults = FALSE;
    
    NSArray* items = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return items;
}

@end
