//
//  BookEntryBase.m
//  MyLauncher
//
//  Created by ramonqlee on 11/14/12.
//
//

#import "BookEntryBase.h"
#import "CommonHelper.h"
#import "CoreDataMgr.h"
#import "Tree.h"
#import "AppDelegate.h"


@implementation RJSingleBook

@synthesize name,icon,pages,pageSize,bookFullPathName,author,summary,url,category,subcategory;

-(NSString*)bookFullPathName
{
    return [RJSingleBook getBookFileName:self.name];
}
+(NSString*)getMaxSizeFileName:(NSString*)path hasSuffix:(NSString*)suffix
{
    //enumerate file among this directory and return the max-sized file name
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSDirectoryEnumerator* enumerator = [fileMgr enumeratorAtPath:path];
    NSString* fileName=@"";
    NSString* retFileName = @"";
    NSError * error;
    unsigned long long fileSize = 0;
    
    while (fileName=[enumerator nextObject]) {
        if([suffix length]==0 || [fileName hasSuffix:suffix])
        {
            NSLog(@"list file:%@",[path stringByAppendingPathComponent:fileName]);
            NSDictionary* dict = [fileMgr attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName]error:&error];
            if (dict) {
                if([dict fileSize]>=fileSize)
                {
                    retFileName = fileName;
                    fileSize = [dict fileSize];
                }
            }
        }
    }
    NSLog(@"recognize file:%@",retFileName);
    return retFileName;
}

+(id)singleBookWithFileModel:(FileModel*)fileModel
{
    RJSingleBook* book = [[[RJSingleBook alloc]init]autorelease];
    //init with filemodel
    book.name = fileModel.bookName;
    if (!book.name || book.name.length == 0) {
        book.name = fileModel.fileName;
    }
    book.author = fileModel.author;
    book.summary = fileModel.summary;
    book.url = fileModel.fileURL;
    book.category = fileModel.category;
    book.subcategory = fileModel.subcategory;
    book.icon = fileModel.icon;
    book.pages = fileModel.pages;
    book.pageSize = fileModel.pageSize;
    book.bookFullPathName = [RJSingleBook getBookFileName:fileModel.bookName];
    
    return book;
}
+(NSString*)getBookFileName:(NSString*)bookName
{
    NSString* bookFullPathName = @"";
    NSString * file = [RJSingleBook getMaxSizeFileName:[CommonHelper getTargetBookPath:bookName] hasSuffix:@".txt"];
    if (file && [file length]>0) {
        bookFullPathName = [[CommonHelper getTargetBookPath:bookName] stringByAppendingPathComponent:file];
        return bookFullPathName;
    }
    
    file = [RJSingleBook getMaxSizeFileName:[CommonHelper getTargetBookPath:bookName] hasSuffix:kDownloadFileSuffix];
    if (file && [file length]>0)
    {
        bookFullPathName = [[CommonHelper getTargetBookPath:bookName] stringByAppendingPathComponent:[RJSingleBook getMaxSizeFileName:[CommonHelper getTargetBookPath:bookName] hasSuffix:kDownloadFileSuffix]];
    }
    else
    {
        bookFullPathName = [[CommonHelper getTargetBookPath:bookName] stringByAppendingPathComponent:[RJSingleBook getMaxSizeFileName:[CommonHelper getTargetBookPath:bookName] hasSuffix:@""]];
    }
    
    return bookFullPathName;
}

@end

@interface BookEntryBase()
{
    CoreDataMgr* mgr;
}
@end

@implementation BookEntryBase
@synthesize books;
@synthesize entryName;

-(id)initWithEntry:(NSString*)name
{
    if (self = [super init]) {
        books = [[NSMutableArray alloc]initWithCapacity:1];
        self.entryName = name;
    }
    return self;
}


#pragma mark Book Edit
-(void)addBook:(RJSingleBook*)b
{
    [self.books addObject:b];
    [self save2CoreData:b];
}
-(void)removeBook:(RJSingleBook*)book
{
    if (!book) {
        return;
    }
    //TODO::
    NSUInteger i = [self indexOfObject:book.name];
    if (kNotFound!=i) {
        [self.books removeObjectAtIndex:i];
        [self removeFromCoreData:book];
    }
}

-(void)editBook:(RJSingleBook*)book
{
    if (!book) {
        return;
    }
    //TODO::find book in books and update in coredata
    NSUInteger i = 0;
    BOOL found = NO;
    for (RJSingleBook* item in self.books) {
        if ([book.name isEqualToString:item.name
             ]) {
            //update current cache & data in coredata
            //item.bookFullPathName = book.bookFullPathName;
            [self.books replaceObjectAtIndex:i withObject:book];
            
            [self updateCoreData:book];
            found = YES;
            break;
        }
        ++i;
    }
    
    if (!found) {
        [self addBook:book];
    }
    
}
//TODO: to be continued
-(void)removeFromCoreData:(RJSingleBook*) b
{
    if(!mgr)
    {
        mgr = [CoreDataMgr coreDataMgrWithEntry:entryName sortKey:nil ascending:NO];
    }
    if(b)
    {
        for (Tree* item in mgr.mLogData) {
            if (item && [item.name isEqualToString:b.name]) {
                [mgr removeObject:item];
                break;
            }
        }
    }
}
-(void)removeAllBooks
{
    if(!mgr)
    {
        mgr = [CoreDataMgr coreDataMgrWithEntry:entryName sortKey:nil ascending:NO];
    }
    [mgr removeAllObjects];
}
-(void)updateCoreData:(RJSingleBook*) b
{
    if(!mgr)
    {
        mgr = [CoreDataMgr coreDataMgrWithEntry:entryName sortKey:nil ascending:NO];
    }
    if(b)
    {
        //TODO::position with name and replace original object
        Tree* item = nil;
        for (item in mgr.mLogData)
        {
            if([item.name isEqualToString:b.name])
            {                
                break;
            }
            item = nil;
        }
        if(item)
        {
            [mgr removeObject:item];
            
            [CommonHelper save2CoreData:b entryName:entryName inCoreData:mgr];
        }else
        {
            [self save2CoreData:b];
        }
    }
}
-(void)save2CoreData:(RJSingleBook*) b
{
    if(!mgr)
    {
        mgr = [CoreDataMgr coreDataMgrWithEntry:entryName sortKey:nil ascending:NO];
    }
    if(b)
    {
        [CommonHelper save2CoreData:b entryName:entryName inCoreData:mgr];
    }
}
-(void)loadFromCoreData
{
    if(!mgr)
    {
        mgr = [CoreDataMgr coreDataMgrWithEntry:entryName sortKey:nil ascending:NO];
    }
    //TODO::load from coredata
    //iterate
    NSLog(@"all objects in log database:%d",[mgr count]);
    for (NSInteger i = 0; i < [mgr count]; ++i) {
        Tree* b = [mgr objectAtIndex:i];
        if (!b || [b.name length]==0 || kNotFound != [self indexOfObject:b.name]) {
            continue;
        }
        RJSingleBook* item = [[RJSingleBook alloc]init];
        item.name = b.name;
        item.icon = b.image;
        //default null icon
        if ([item.icon length]==0) {
            item.icon = kDefaultBookIcon;
        }
        item.bookFullPathName = b.filename;
        item.author=b.author;
        item.summary=b.summary;
        item.url=b.url;
        item.category=b.category;
        item.subcategory=b.subcategory;
        
        [books addObject:item];
        NSLog(@":bookName:%@,bookFilePath:%@",item.name,item.bookFullPathName);
        [item release];
    }
}
-(NSUInteger)indexOfObject:(NSString*)bookName
{
    if (!self.books || [self.books count]==0) {
        return kNotFound;
    }
    for (NSUInteger i = 0; i< [self.books count]; ++i) {
        RJSingleBook* item = [self.books objectAtIndex:i];
        if(item && [item.name isEqualToString:bookName])
        {
            return i;
        }
    }
    return kNotFound;
}
-(void)importXml:(NSString*) xmlFile
{
    NSArray* books = [CommonHelper parseBookXml:xmlFile];
    for (RJSingleBook* b in books) {
        if (b && kNotFound == [self indexOfObject:b.name]) {
            [self.books addObject:b];
            [self save2CoreData:b];
        }
    }
}
-(BOOL) loadXml:(NSString*) xmlFile
{
    NSString* kLoadedXMLKey = entryName;
    NSUserDefaults* defaultSetting = [NSUserDefaults standardUserDefaults];
    //NSString* v = [defaultSetting valueForKey:kLoadedXMLKey];
    //if(!v || [v length]==0)
    {
        [defaultSetting setValue:@"1" forKey:kLoadedXMLKey];
        [self importXml:xmlFile];
    }
    [self loadFromCoreData];
    return YES;
}
@end

