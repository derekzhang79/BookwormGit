//
//  ProtocolLogManager.h
//  today
//
//  Created by li ming on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**how to use 
 
 CoreDataMgr* mgr = [CoreDataMgr sharedCoreDataMgr:entryName sortKey:key ascending:ascending];
 
 //iterate
 NSLog(@"all objects in log database");
 for (NSInteger i = 0; i < [mgr count]; ++i) {
 Log* log = [mgr objectAtIndex:i];
 NSLog(@"%@-%@-%@",log.type,log.status,log.time);
 }
 
 //remove certain object      
 [mgr removeObjectAtIndex:1];
 
 //clear
 [mgr removeAllObjects];
 
 */


#import <Foundation/Foundation.h>

@interface CoreDataMgr : NSObject
{
    NSMutableArray* mLogData;
}

@property(nonatomic,assign) NSMutableArray* mLogData;

//key can be null
+(id)sharedCoreDataMgr:(NSString*)entryName sortKey:(NSString*)key ascending:(BOOL)ascending;
+(void)reset;
+(id)coreDataMgrWithEntry:(NSString*)entryName sortKey:(NSString*)key ascending:(BOOL)ascending;

-(NSUInteger)count;

-(id)objectAtIndex:(NSUInteger)index;

-(void)addObject:(id)obj;

-(void)addObject2Front:(id)obj;

-(void)removeObjectAtIndex:(NSUInteger)index;

-(void)removeObject:(id)obj;

-(void)removeAllObjects;

-(BOOL)replaceObject:(id)obj;
@end
