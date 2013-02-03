//
//  MusicModel.m
//  Hayate
//
//  Created by 韩 国翔 on 11-12-2.
//  Copyright 2011年 山东海天软件学院. All rights reserved.
//

#import "FileModel.h"
#import "BookEntryBase.h"
#import "CommonHelper.h"


@implementation FileModel
@synthesize fileID;
@synthesize fileName;
@synthesize fileType;
@synthesize fileSize;
@synthesize isFistReceived;
@synthesize fileReceivedData;
@synthesize fileReceivedSize;
@synthesize fileURL;
@synthesize isDownloading;
@synthesize isP2P;
@synthesize bookName;
@synthesize summary;
@synthesize category;
@synthesize subcategory;
@synthesize pages;
@synthesize pageSize;
@synthesize author;
@synthesize icon;


+(FileModel*)fileModelFromRJSingleBook:(RJSingleBook*)book
{
    FileModel* filemodel = [[[FileModel alloc]init]autorelease];
    filemodel.author = book.author;
    filemodel.fileName = [book.name stringByAppendingString:kDownloadFileSuffix];
    filemodel.fileURL = book.url;
    filemodel.bookName = book.name;
    filemodel.summary = book.summary;
    filemodel.category = book.category;
    filemodel.subcategory = book.subcategory;
    filemodel.pages = book.pages;
    filemodel.pageSize = book.pageSize;
    filemodel.icon = book.icon;
    filemodel.bookName = book.name;
    //根据文件名获取文件的大小
    filemodel.fileSize=[CommonHelper getFileSizeStringWithFileName:book.bookFullPathName];
    
    
    return filemodel;
}

-(void)dealloc
{
    [author release];
    [summary release];
    [category release];
    [subcategory release];
    [pages release];
    [pageSize release];
    
    [fileID release];
    [fileName release];
    [fileType release];
    [fileSize release];
    [fileReceivedSize release];
    [fileReceivedData release];//接受的数据
    [fileURL release];
    [bookName release];
    [icon release];
    [super dealloc];
}
@end
