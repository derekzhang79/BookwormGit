//
//  CommonHelper.m
//  Hayate
//
//  Created by 韩 国翔 on 11-12-2.
//  Copyright 2011年 山东海天软件学院. All rights reserved.
//

#import "CommonHelper.h"
#import "ZipArchive.h"
#import "Unrar4iOSEx.h"
#import "TouchXML.h"
#import "RJBookData.h"
#import "CoreDataMgr.h"
#import "Tree.h"
#import "AppDelegate.h"
#import "LatestBooks.h"

@implementation CommonHelper

//+(NSString *)transformToM:(NSString *)size
//{
//    float oldSize=[size floatValue];
//    float newSize=oldSize/1024.0f;
//    newSize=newSize/1024.0f;
//    return [NSString stringWithFormat:@"%f",newSize];
//}
//
//+(float)transformToBytes:(NSString *)size
//{
//    float totalSize=[size floatValue];
////    NSLog(@"文件总大小跟踪：%f",totalSize);
//    return totalSize*1024*1024;
//}

+(NSString *)getFileSizeString:(NSString *)size
{
    if([size floatValue]>=1024*1024)//大于1M，则转化成M单位的字符串
    {
        return [NSString stringWithFormat:@"%fM",[size floatValue]/1024/1024];
    }
    else if([size floatValue]>=1024&&[size floatValue]<1024*1024) //不到1M,但是超过了1KB，则转化成KB单位
    {
        return [NSString stringWithFormat:@"%fK",[size floatValue]/1024];
    }
    else//剩下的都是小于1K的，则转化成B单位
    {
        return [NSString stringWithFormat:@"%fB",[size floatValue]];
    }
}

+(float)getFileSizeNumber:(NSString *)size
{

    NSInteger indexM=[size rangeOfString:@"M"].location;
    NSInteger indexK=[size rangeOfString:@"K"].location;
    NSInteger indexB=[size rangeOfString:@"B"].location;
    if(indexM<1000)//是M单位的字符串
    {
        return [[size substringToIndex:indexM] floatValue]*1024*1024;
    }
    else if(indexK<1000)//是K单位的字符串
    {
        return [[size substringToIndex:indexK] floatValue]*1024;
    }
    else if(indexB<1000)//是B单位的字符串
    {
        return [[size substringToIndex:indexB] floatValue];
    }
    else//没有任何单位的数字字符串
    {
        return [size floatValue];
    }
}
+(NSString *)getFileSizeStringWithFileName:(NSString *)fileName
{
    NSDictionary* dict = [[NSFileManager defaultManager]attributesOfItemAtPath:fileName error:nil];
    NSNumber* fileSize = [dict objectForKey:NSFileSize];
    
    return [CommonHelper getFileSizeString:fileSize.stringValue];
}
+(NSString*) getTargetBookPath:(NSString*)bookName
{
    NSString *documentsDirectory = [CommonHelper getTargetFolderPath];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Books/%@",bookName]];

}

+(NSString *)getDocumentPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
}

+(NSString *)getTargetFolderPath
{
    return [self getDocumentPath];
}

+(NSString *)getTempFolderPath
{
    return [[self getDocumentPath] stringByAppendingPathComponent:@"Temp"];
}

+(BOOL)isExistFile:(NSString *)fileName
{
    if (!fileName || [fileName length]==0) {
        return NO;
    }
    NSFileManager *fileManager=[NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:fileName];
}

+(float)getProgress:(float)totalSize currentSize:(float)currentSize
{
    const float kZero = 0.01;
    if (currentSize<kZero || totalSize < kZero) {
        return 0;
    }
    return currentSize/totalSize;
}

#define kDotString @"."
#define kZipPackage @".zip"
#define kRarPackage @".rar"
#define kTxtPackage @".txt"
//extract packaged file to desFile
//zip,rar are supported right now
+(void)extractFile:(NSString*)srcFile toFile:(NSString*)desFilePath fileType:(NSString*)fileType
{
    //find suffix and try to extract the
    if (!srcFile || ![CommonHelper isExistFile:srcFile]) {
        return;
    }
    [CommonHelper makesureDirExist:desFilePath];
    if (fileType && [fileType isEqualToString:@"text/plain"]) {
        [CommonHelper copyFile:srcFile toFile:[desFilePath stringByAppendingPathComponent:[srcFile lastPathComponent]]];
        return;
    }
    
    NSRange range = [[srcFile lastPathComponent] rangeOfString:kDotString options:NSBackwardsSearch];
    BOOL extracted = NO;
    if(0!=range.length)
    {
        NSString* suffix = [srcFile substringFromIndex:range.location];
        if (NSOrderedSame == [kZipPackage caseInsensitiveCompare:suffix]) {
            extracted = [CommonHelper unzipFile:srcFile toFile:desFilePath];
        }
        else if (NSOrderedSame == [kRarPackage caseInsensitiveCompare:suffix]) {
            extracted = [CommonHelper unrarFile:srcFile toFile:desFilePath];
        }
        else if (NSOrderedSame == [kTxtPackage caseInsensitiveCompare:suffix]) {
            extracted = [CommonHelper copyFile:srcFile toFile:desFilePath];
        }
    }
    
    if(0==range.length || !extracted)//oops,not found
    {
        //try zip-->rar-->copy directly
        if ([CommonHelper unzipFile:srcFile toFile:desFilePath]) {
            return;
        }
        if ([CommonHelper unrarFile:srcFile toFile:desFilePath]) {
            return;
        }
        [CommonHelper copyFile:srcFile toFile:[desFilePath stringByAppendingPathComponent:[srcFile lastPathComponent]]];
        return;
    }
}

+(BOOL)copyFile:(NSString*)srcFile toFile:(NSString*)desFile
{
    NSMutableData *writer = [[NSMutableData alloc]init];
    [CommonHelper makesureDirExist:[desFile stringByDeletingLastPathComponent]];
    
    NSData *reader = [NSData dataWithContentsOfFile:srcFile];
    [writer appendData:reader];
    [writer writeToFile:desFile atomically:YES];
    [writer release];
    return YES;
}
+(BOOL)unzipFile:(NSString*)zipFile toFile:(NSString*)unzipFile
{
    if (!zipFile || !unzipFile ) {
        return NO;
    }
    if(![[NSFileManager defaultManager]fileExistsAtPath:zipFile])
    {
        return NO;
    }
    
    BOOL ret = NO;
    ZipArchive* zip = [[ZipArchive alloc] init];
    if( [zip UnzipOpenFile:zipFile] ){
        ret = [zip UnzipFileTo:unzipFile overWrite:YES];
        if( NO==ret ){
            //添加代码
        }
        [zip UnzipCloseFile];
    }
    [zip release];
    return ret;
}
+(BOOL)unrarFile:(NSString*)rarFile toFile:(NSString*)unrarFile
{
    BOOL ret = NO;
    if (!rarFile || !unrarFile ) {
        return ret;
    }
    if(![[NSFileManager defaultManager]fileExistsAtPath:rarFile])
    {
        return ret;
    }
    
	Unrar4iOSEx *unrar = [[Unrar4iOSEx alloc] init];
	if ([unrar unrarOpenFile:rarFile]) {
		ret = [unrar unrarFileTo:unrarFile overWrite:YES];
    }
    
    [unrar unrarCloseFile];
    
	[unrar release];
    return ret;
}
+(NSString*)retBookFileNameInDirectory:(NSString*)path
{
    NSString* bookFileName = @"";
    //TODO::find book name in this directory
    //1.get file path
    //2.assume maximum-sized file in this path what we need
    
    return bookFileName;
}
+(void)makesureDirExist:(NSString*)directory
{
    NSError* err;
    //BOOL dir = NO;
    //if(![[NSFileManager defaultManager]fileExistsAtPath:directory isDirectory:&dir])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
    }
}


+(NSArray*)parseBookXml:(NSString*) XMLPath
{
    NSMutableArray* books = [NSMutableArray arrayWithCapacity:1];
    NSData *XMLData = [NSData dataWithContentsOfFile:XMLPath];
    CXMLDocument *document = [[CXMLDocument alloc] initWithData:XMLData
                                                        options:0
                                                          error:nil
                              ];
    
    CXMLNode* bookData = [document nodeForXPath:@"//books" error:nil];
    for (CXMLElement *element in bookData.children)
    {
        if ([element isKindOfClass:[CXMLElement class]])
        {
            RJSingleBook* singleBook = [[RJSingleBook alloc]init];
            for (int i = 0; i < [element childCount]; i++)
            {
                CXMLNode* node = [[element children] objectAtIndex:i];
                if([[node name] isEqualToString:@"name"])
                {
                    singleBook.name = [node stringValue];
                    NSLog(@"%@",singleBook.name);
                }
                if([[node name] isEqualToString:@"icon"])
                {
                    singleBook.icon = [node stringValue];
                    if ([singleBook.icon length]==0) {
                        singleBook.icon = kDefaultBookIcon;
                    }
                    NSLog(@"%@",singleBook.icon);
                }
                
                if([[node name] isEqualToString:@"author"])
                {
                    singleBook.author = [node stringValue];
                    NSLog(@"%@",singleBook.author);
                }
                if([[node name] isEqualToString:@"summary"])
                {
                    singleBook.summary = [node stringValue];
                    NSLog(@"%@",singleBook.summary);
                }
                if([[node name] isEqualToString:@"url"])
                {
                    singleBook.url = [node stringValue];
                    NSLog(@"%@",singleBook.url);
                }
                if([[node name] isEqualToString:@"category"])
                {
                    singleBook.category = [node stringValue];
                    NSLog(@"%@",singleBook.category);
                }
                
                if([[node name] isEqualToString:@"subcategory"])
                {
                    singleBook.subcategory = [node stringValue];
                    NSLog(@"%@",singleBook.subcategory);
                }
                
                
                if([[node name] isEqualToString:@"pages"])
                {
                    CXMLNode* pages = node;
                    singleBook.pages = [[NSMutableArray alloc]initWithCapacity:1];
                    singleBook.pageSize  = [[NSMutableArray alloc]initWithCapacity:1];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error;
                    for (CXMLNode *pageNode in pages.children)
                    {
                        if ([pageNode isKindOfClass:[CXMLNode class]] && [[pageNode name] isEqualToString:@"page"])
                        {
                            [singleBook.pages addObject:[pageNode stringValue] ];
                            NSLog(@"%@",[pageNode stringValue] );
                            NSString *path = [[NSBundle mainBundle]pathForResource:[pageNode stringValue] ofType:nil] ;
                            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:&error];
                            NSUInteger fileSize = 0;
                            if (fileAttributes) {
                                fileSize = [[fileAttributes objectForKey:NSFileSize] unsignedIntegerValue];
                            }
                            NSLog(@"%@",[NSString stringWithFormat:@"%d",fileSize]);
                            [singleBook.pageSize addObject: [NSString stringWithFormat:@"%d",fileSize]];
                        }
                    }
                    //                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [CommonHelper getTargetFolderPath];//[paths objectAtIndex:0];//去处需要的路径
                    NSString *path = [documentsDirectory stringByAppendingPathComponent:singleBook.name];
                    singleBook.bookFullPathName = [path stringByAppendingPathExtension:kDownloadFileSuffix];
                    
                    /*if (![fileManager fileExistsAtPath:singleBook.bookFullPathName])
                     {
                     [fileManager createFileAtPath:singleBook.bookFullPathName contents:nil attributes:nil];
                     NSMutableData *writer = [[NSMutableData alloc]init];
                     for(NSInteger i=0;i<[singleBook.pages count];i++)
                     {
                     NSString* file = [singleBook.pages objectAtIndex:i];
                     NSString *path = [[NSBundle mainBundle]pathForResource:file  ofType:nil] ;
                     NSData *reader = [NSData dataWithContentsOfFile:path];
                     [writer appendData:reader];
                     }
                     [writer writeToFile:singleBook.bookFullPathName atomically:YES];
                     [writer release];
                     }*/
                }
            }
            [books addObject:singleBook];
            [singleBook release];
        }
    }
    [document release];
    
    return books;
}
+(BOOL)itemExistedInCoreData:(RJSingleBook*) b inCoreData:(CoreDataMgr*)mgr
{
    if (!b || !mgr) {
        return NO;
    }
    for (Tree* t in mgr.mLogData) {
        if(t && [t.name isEqualToString:b.name])
        {
            return YES;
        }
    }
    return NO;
}
+(void)save2CoreData:(RJSingleBook*) b entryName:(NSString*)entryName inCoreData:(CoreDataMgr*)mgr
{
    if(!mgr || !b || [CommonHelper itemExistedInCoreData:b inCoreData:mgr] || !entryName || [entryName length]==0 || !b.name ||
       [b.name length]==0)
    {
        return;
    }
    
    NSManagedObjectContext* managedObjectContext = MANAGED_CONTEXT;
    Tree* item = (Tree*)[NSEntityDescription insertNewObjectForEntityForName:entryName inManagedObjectContext:managedObjectContext];
    
    item.name = b.name;
    item.image = b.icon;
    item.filename = b.bookFullPathName;
    item.author=b.author;
    item.summary=b.summary;
    item.url=b.url;
    item.category=b.category;
    item.subcategory=b.subcategory;
    
    //add default icon
    if (!item.image || [item.image stringByReplacingOccurrencesOfString:@" " withString:@""].length==0) {
        item.image = kDefaultBookIcon;
    }
    [mgr addObject:item];
    NSLog(@"add book,name:%@--filename:%@",item.name,item.filename);
}

+(NSStringEncoding)dataEncoding:(const Byte*) header
{
    NSStringEncoding encoding = NSUTF8StringEncoding;
    if(header)
    {
        if ( !(header[0]==0xff || header[0] == 0xfe) ) {
            encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        }
    }
    return encoding;
}
+(void)deleteFinishedBook:(FileModel*)fileModel
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    NSString *path=[[CommonHelper getTargetFolderPath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",fileModel.fileName]];
    
    [fileManager removeItemAtPath:path error:&error];
    if(!error)
    {
        NSLog(@"%@",[error description]);
    }
    
    //delete downloaded file
    LatestBooks* b = [LatestBooks shareInstance];
    RJSingleBook* book = [RJSingleBook singleBookWithFileModel:fileModel];
    [b removeBook:book];
    [fileManager removeItemAtPath:book.bookFullPathName error:&error];
    
}
@end
