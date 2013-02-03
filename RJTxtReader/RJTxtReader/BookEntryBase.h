//
//  BookEntryBase.h
//  MyLauncher
//
//  Created by ramonqlee on 11/14/12.
//
//

#import <Foundation/Foundation.h>

@class FileModel;
@class CoreDataMgr;

@interface RJSingleBook : NSObject
{
    NSString* name;
    NSString* icon;
    NSString* bookFullPathName;//absolute file name
    NSString * author;
    NSString * summary;
    NSString * url;
    NSString * category;//类别，客户端分类展示时使用
    NSString * subcategory;
    NSUInteger position;//position in reader's view
    //预留区域
    NSMutableArray* pages;//分章使用，暂时服务器端不支持，但客户端已经支持
    NSMutableArray* pageSize;
    
}
@property(nonatomic,retain) NSString* name;
@property(nonatomic,retain) NSString* icon;
@property(nonatomic,retain) NSString* bookFullPathName;
@property(nonatomic,retain) NSString* author;
@property(nonatomic,retain) NSString* summary;
@property(nonatomic,retain) NSString* url;
@property(nonatomic,retain) NSString* category;
@property(nonatomic,retain) NSString* subcategory;
@property(nonatomic,retain) NSMutableArray* pages;
@property(nonatomic,retain) NSMutableArray* pageSize;

+(id)singleBookWithFileModel:(FileModel*)fileModel;
+(NSString*)getBookFileName:(NSString*)bookName;
@end

@interface BookEntryBase : NSObject
{
    NSMutableArray* books;
    NSString* entryName;
}
-(id)initWithEntry:(NSString*)entryName;
@property(nonatomic,retain) NSMutableArray* books;
@property(nonatomic,retain) NSString* entryName;

-(void)save2CoreData:(RJSingleBook*) b;
-(void)loadFromCoreData;

-(void)importXml:(NSString*) xmlFile;//import xml data into coredata

-(BOOL) loadXml:(NSString*) xmlFile;//import xml data into coredata once,if imported already,just load them into cache

-(NSUInteger)indexOfObject:(NSString*)bookName;
-(void)addBook:(RJSingleBook*)book;
-(void)removeBook:(RJSingleBook*)book;
-(void)editBook:(RJSingleBook*)book;
-(void)removeAllBooks;
@end
