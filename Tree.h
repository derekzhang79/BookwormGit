//
//  Tree.h
//  MyLauncher
//
//  Created by ramonqlee on 11/9/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kBookEntry @"Tree"//all books
#define kLatestEntry @"LatestEntry"//latest books
#define kRecommendList @"RecommendList"

@interface Tree : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * filesize;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * index;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * subcategory;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * url;

@end
