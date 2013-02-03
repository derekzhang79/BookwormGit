//
//  KDBook.m
//  Gether
//
//  Created by lucky on 12-8-9.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "KDBook.h"
#import "CommonHelper.h"
#import "LatestBooks.h"

#define kInvalidEncoding (-1)
#define kDefaultPages 3
#define kMinBookSize 1024

@implementation KDBook
@synthesize bookIndex;
@synthesize textFont;
@synthesize pageSize;
@synthesize delegate;
@synthesize bookSize;

- (NSString *)filePath:(NSString *)fileName{
	if (fileName == nil) {
		return nil;
	}
    
	return fileName;
}

- (NSFileHandle *)handleWithFile:(NSString *)fileName {
    if (fileName == nil) {
		//  print : wrong file name;
		return nil;
	}
	NSString *path = [self filePath:fileName];
	if (path == nil) {
		//  print : can not find the file
		return nil;
	}
	return [NSFileHandle fileHandleForReadingAtPath:path];
}

- (unsigned long long)fileLengthWithFile:(NSString *)fileName{
	if (fileName == nil) {
		return (0);
	}
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path = [self filePath:fileName];
	NSError *error;
	NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:&error];
	if (!fileAttributes) {
		NSLog(@"%@",error);
		return (0);
	}
	return [[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];
}


//偏移量调整（防止英文字符 一个单词被分开）
- (unsigned long long)fixOffserWith:(NSFileHandle *)handle{
	unsigned long long offset = [handle offsetInFile];
	if (offset == 0) {
		return (0);
	}
	NSData *oData = [handle readDataOfLength:1];
	if (oData) {
		NSString *jStr = [[NSString alloc]initWithData:oData encoding:encoding];
		if (jStr) {
			char *oCh = (char *)[oData bytes];
			while  ((*oCh >= 65 && *oCh <= 90) || (*oCh >= 97 && *oCh <= 122)) {
				[handle seekToFileOffset:--offset];
				NSData *jData = [handle readDataOfLength:1];
				NSString *kStr = [[NSString alloc]initWithData:jData encoding:encoding];
				if (kStr == nil || offset == 0) {
					[kStr release];
					break;
				}
				[kStr release];
				oCh = (char *)[jData bytes];
			}
			offset++;
		}
		[jStr release];
	}
	return offset;
}

- (void)showFirstPage{
	if (delegate && [(NSObject *)delegate respondsToSelector:@selector(firstPage:)] && [pageIndexArray count]>0) {
        RJSingleBook* singleBook = [[LatestBooks shareInstance].books objectAtIndex:bookIndex];
		NSFileHandle *handle = [self handleWithFile:singleBook.bookFullPathName];
		NSData *data = [handle readDataOfLength:[[pageIndexArray objectAtIndex:0] unsignedLongLongValue]];
        if (handle) {
            [handle closeFile];
        }
		NSString *string = [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
		if (string) {
			[delegate firstPage:string];
		}
	}
}

- (void)bookDidRead:(NSUInteger)size{
	if (delegate && [(NSObject *)delegate respondsToSelector:@selector(bookDidRead:)] && [pageIndexArray count]>0) {
		[delegate bookDidRead:size];
	}
}
/*
 TODO::return current screen page
 */
- (unsigned long long)indexOfPage:(NSFileHandle *)handle textFont:(UIFont *)font{
	unsigned long long offset = [handle offsetInFile];
	unsigned long long fileSize = bookSize;
	NSUInteger MaxWidth = pageSize.width, MaxHeigth = pageSize.height;
	
    const NSUInteger kGB18030 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    const NSUInteger kEncodings[] = {NSUTF8StringEncoding,kGB18030};
	BOOL isEndOfFile = NO;
	NSUInteger length = 100;
	NSMutableString *labelStr = [[NSMutableString alloc] init];
    const int kMaxEncodingBufferSize = 3;
	do{
		for (int j=0; j<kMaxEncodingBufferSize; j++) {
			if ((offset+length+j) > fileSize) {
				offset = fileSize;
				isEndOfFile = YES;
				break ;
			}
			[handle seekToFileOffset:offset];
			NSData *data = [handle readDataOfLength:j+length];
            
			if (data) {
                
                //try utf-8 and gbk
                NSString *iStr=nil;
                if(encoding == kInvalidEncoding)
                {
                    for (int m = 0; m < sizeof(kEncodings)/sizeof(kEncodings[0]); ++m) {
                        iStr = [[NSString alloc] initWithData:data encoding:kEncodings[m]];
                        if(iStr)
                        {
                            encoding = kEncodings[m];
                            break;
                        }
                    }
                }
                else
                {
                    iStr = [[NSString alloc] initWithData:data encoding:encoding];
                }
				if (iStr ) {
					NSString *oStr = [NSString stringWithFormat:@"%@%@",labelStr,iStr];
					
					CGSize labelSize=[oStr sizeWithFont:font
									  constrainedToSize:CGSizeMake(MaxWidth,1000)
										  lineBreakMode:UILineBreakModeWordWrap];
					if (labelSize.height-MaxHeigth > 0 && length != 1) {
						if (length <= 5) {
							length = 1;
						}else {
							length = length/(2);
						}
					}else if (labelSize.height > MaxHeigth && length == 1) {
						offset = [handle offsetInFile]-length-j;
						[handle seekToFileOffset:offset];
						offset = [self fixOffserWith:handle];
						isEndOfFile = YES;
					}else if(labelSize.height <= MaxHeigth ) {
						[labelStr appendString:iStr];
						offset = j+length+offset;
					}
					[iStr release];
					break ;
				}
				[iStr release];
			}
            else if(kMaxEncodingBufferSize-1 == j)
            {
                offset = -1;
                isEndOfFile = YES;
            }
		}
        
		if (offset >= fileSize) {
			isEndOfFile = YES;
		}
	}while (!isEndOfFile);
	//NSLog(@"offset :%d",offset);
	[labelStr release];
	return offset;
}


#pragma mark lll

- (NSString *)stringWithPage:(NSUInteger)pageIndex{
	if (pageIndex > [pageIndexArray count]) {
		return nil;
	}
    RJSingleBook* singleBook = [[LatestBooks shareInstance].books objectAtIndex:bookIndex];
	NSFileHandle *handle = [self handleWithFile:singleBook.bookFullPathName];
	unsigned long long offset = 0;
	if (pageIndex > 1) {
		offset = [[pageIndexArray objectAtIndex:pageIndex-2]unsignedLongLongValue];
	}
	[handle seekToFileOffset:offset];
	unsigned long long length = [[pageIndexArray objectAtIndex:pageIndex-1]unsignedLongLongValue]-offset;
	NSData *data  = [handle readDataOfLength:length];
    if (handle) {
        [handle closeFile];
    }
	NSString *labelText = [[[NSString alloc] initWithData:data encoding:[self encoding]] autorelease];
	if (labelText == nil) {
		return nil;
	}
    
    //load next pages
    if (pageIndex == [pageIndexArray count]-1) {
        thread = [[NSThread alloc]initWithTarget:self selector:@selector(loadMorePages) object:nil];
        [thread start];
    }
    
    return labelText;
}

- (unsigned long long)offsetWithPage:(NSUInteger)pageIndex
{
    if (pageIndex > [pageIndexArray count]) {
		return 0;
	}
    
	unsigned long long offset = 0;
	if (pageIndex > 1) {
		offset = [[pageIndexArray objectAtIndex:pageIndex-2]unsignedLongLongValue];
	}
    
    return offset;
}

-(void)loadMorePages
{
    if ([pageIndexArray count]==0) {
        return;
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    RJSingleBook* singleBook = [[LatestBooks shareInstance].books objectAtIndex:bookIndex];
	NSFileHandle *handle = [self handleWithFile:singleBook.bookFullPathName];
	NSUInteger count = [pageIndexArray count];
	unsigned long long index = [[pageIndexArray objectAtIndex:count-1] unsignedLongLongValue];
    NSUInteger l=0;
	while (index < bookSize) {
		[handle seekToFileOffset:index];
		index = [self indexOfPage:handle textFont:textFont];
        if (index == -1) {
            break;
        }
		[pageIndexArray addObject:[NSNumber numberWithUnsignedLongLong:index]];
		//NSLog(@"--index:%d",index);
        if(++l>=kDefaultPages)
        {
            break;
        }
	}
    if(handle)
    {
        [handle closeFile];
    }
    [pool release];
    
}
- (void)bookIndex{
    if ([pageIndexArray count]==0) {
        return;
    }
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    RJSingleBook* singleBook = [[LatestBooks shareInstance].books objectAtIndex:bookIndex];
	NSFileHandle *handle = [self handleWithFile:singleBook.bookFullPathName];
	NSUInteger count = [pageIndexArray count];
	unsigned long long index = [[pageIndexArray objectAtIndex:count-1] unsignedLongLongValue];
	while (index < bookSize) {
		[handle seekToFileOffset:index];
		index = [self indexOfPage:handle textFont:textFont];
        if (index == -1) {
            break;
        }
		[pageIndexArray addObject:[NSNumber numberWithUnsignedLongLong:index]];
		//NSLog(@"--index:%d",index);
	}
    if(handle)
    {
        [handle closeFile];
    }
    
	[self bookDidRead:[pageIndexArray count]];
	[pool release];
}


- (void)pageAr{
	if (bookIndex < 0) {
		return ;
	}
    RJSingleBook* singleBook = [[LatestBooks shareInstance].books objectAtIndex:bookIndex];
    NSString* name = singleBook.bookFullPathName;
    NSLog(@"load file:%@",name);
	bookSize = [self fileLengthWithFile:name];
    if (bookSize<kMinBookSize) {
        return;
    }
	NSFileHandle *handle = [self handleWithFile:name];
	unsigned long long index = 0;
	pageIndexArray = [[NSMutableArray alloc] init];
	for (int i=0; i<kDefaultPages; i++)  {
		index = [self indexOfPage:handle textFont:textFont];
        if (index == -1) {
            break;
        }
		[pageIndexArray addObject:[NSNumber numberWithUnsignedLongLong:index]];
		[handle seekToFileOffset:index];
	}
    if (handle) {
        [handle closeFile];
    }
	[self showFirstPage];
	
    //TODO::optimized to load when need(last read page)
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger lastPage = [saveDefaults integerForKey:singleBook.name];
    if(lastPage > kDefaultPages)
    {
        thread = [[NSThread alloc]initWithTarget:self selector:@selector(bookIndex) object:nil];
        [thread start];
    }
}

#pragma mark NSObject FUNCTION


- (id)init{
	self = [super init];
	if (self) {
		//add your code here
		pageIndexArray = nil;
		bookIndex = -1;
        bookPageIndex = 0;
		textFont = [[UIFont systemFontOfSize:kContentTextSize] retain];
	    pageSize = [[UIScreen mainScreen] applicationFrame].size;//CGSizeMake(kDeviceWidth, KDeviceHeight);
        encoding = kInvalidEncoding;
	}
	return self;
}

- (id)initWithBook:(NSInteger)newBookIndex{
	self = [self init];
	if (self) {
		bookIndex = newBookIndex;
	}
	
	return self;
}
-(void)startAutoPageSplit
{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(pageAr) userInfo:nil repeats:NO];
}
- (void) createBook
{
    
}

- (void)dealloc{
	[thread release];
	[pageIndexArray release];
	[textFont release];
	[super dealloc];
}

- (void)setDelegate:(id <KDBookDelegate>)dele{
	delegate = dele;
	if (delegate == nil) {
		[thread cancel];		
		thread = nil;
	}
}
-(NSStringEncoding)encoding
{
    return encoding;
}
@end
