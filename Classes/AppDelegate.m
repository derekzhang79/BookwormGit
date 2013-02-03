//
//  AppDelegate.m
//  @rigoneri
//
//  Copyright 2010 Rodrigo Neri
//  Copyright 2011 David Jarrett
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "AppDelegate.h"
#import "RJBookData.h"
#import "LatestBooks.h"
#import "RecommendList.h"
#import "GHMenuCell.h"
#import "GHMenuTitle.h"
#import "GHMenuViewController.h"
#import "GHRootViewController.h"
#import "GHRevealViewController.h"
#import "GHSidebarSearchViewController.h"
#import "GHSidebarSearchViewControllerDelegate.h"
#import "BookStoreViewController.h"
#import "InAppRageIAPHelper.h"
#import "Flurry.h"
#import "ASIFormDataRequest.h"
#import "EmbarassViewController.h"
#import "MoreViewController.h"
#import "SoftRcmListViewController.h"
#import "iTellAFriend.h"
#import "AdsConfig.h"
#import "YouMiWall.h"

#define kMaxConcurrentOperationCount 1

#define kLocalBooksName @"bookwormbooks.xml"
#define kServerBooksUrl @"http://www.idreems.com/rss-channels.php?channel=bookwormbooks"

#pragma mark -
#pragma mark Private Interface
@interface AppDelegate () <GHSidebarSearchViewControllerDelegate>
@property (nonatomic, retain) GHRevealViewController *revealController;
@property (nonatomic, retain) GHSidebarSearchViewController *searchController;
@property (nonatomic, retain) GHMenuViewController *menuController;
-(void)initBookData:(NSObject*)obj;
@end

#define kLocalBooks @"localBooks.xml"
#define kServerBookFile @"severBooks.xml"

#define kUpdateApp 0
#define kOpenWeixin 1

@implementation AppDelegate
@synthesize revealController, searchController, menuController;
@synthesize window, navigationController;

@synthesize downinglist=_downinglist;

@synthesize downloadDelegate=_downloadDelegate;

@synthesize finishedlist=_finishedlist;

@synthesize buttonSound=_buttonSound;

@synthesize downloadCompleteSound=_downloadCompleteSound;

@synthesize isFistLoadSound=_isFirstLoadSound;
@synthesize mTrackViewUrl;
@synthesize mBookData;


-(void)playButtonSound
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *result=[userDefaults objectForKey:@"isOpenAudio"];
    NSURL *url=[[[NSBundle mainBundle]resourceURL] URLByAppendingPathComponent:@"btnEffect.wav"];
    NSError *error;
    if(self.buttonSound==nil)
    {
        self.buttonSound=[[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] autorelease];
        if(!error)
        {
            NSLog(@"%@",[error description]);
        }
    }
    if([result isEqualToString:@"YES"]||result==nil)//播放声音
    {
        if(!self.isFistLoadSound)
        {
            self.buttonSound.volume=1.0f;
        }
    }
    else
    {
        self.buttonSound.volume=0.0f;
    }
    [self.buttonSound play];
#endif
}

-(void)playDownloadFinishSound
{
#if !(TARGET_IPHONE_SIMULATOR)
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *result=[userDefaults objectForKey:@"isOpenAudio"];
    NSURL *url=[[[NSBundle mainBundle]resourceURL] URLByAppendingPathComponent:@"download-complete.wav"];
    NSError *error;
    if(self.downloadCompleteSound==nil)
    {
        self.downloadCompleteSound=[[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] autorelease];
        if(!error)
        {
            NSLog(@"%@",[error description]);
        }
    }
    if([result isEqualToString:@"YES"]||result==nil)//播放声音
    {
        if(!self.isFistLoadSound)
        {
            self.downloadCompleteSound.volume=1.0f;
        }
    }
    else
    {
        self.downloadCompleteSound.volume=0.0f;
    }
    [self.downloadCompleteSound play];
#endif
}
-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown setAllowResumeForFileDownloads:(BOOL)allow
{
    //如果不存在则创建临时存储目录
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:[CommonHelper getTempFolderPath]])
    {
        [fileManager createDirectoryAtPath:[CommonHelper getTempFolderPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    //按照获取的文件名获取临时文件的大小，即已下载的大小
    fileInfo.isFistReceived=YES;
    NSData *fileData=[fileManager contentsAtPath:[[CommonHelper getTempFolderPath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",fileInfo.fileName]]];
    NSInteger receivedDataLength=[fileData length];
    fileInfo.fileReceivedSize=[NSString stringWithFormat:@"%d",receivedDataLength];
    //url encoding
    NSString* fileURL = ([fileInfo.fileURL rangeOfString:@"%"].length==0)?[fileInfo.fileURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:fileInfo.fileURL;
    //如果文件重复下载或暂停、继续，则把队列中的请求删除，重新添加
    for(ASIHTTPRequest *tempRequest in self.downinglist)
    {
        FileModel *f =(FileModel *)[tempRequest.userInfo objectForKey:@"File"];
        NSString* url = ([f.fileURL rangeOfString:@"%"].length==0)?[f.fileURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:f.fileURL;
        if([url isEqual:fileURL])
        {
            [tempRequest cancel];
            [_downinglist removeObject:tempRequest];
            break;
        }
    }
    
    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:fileURL]];
    request.delegate=self;
    [request setDownloadDestinationPath:[[CommonHelper getTargetFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileInfo.fileName]]];
    [request setTemporaryFileDownloadPath:[[CommonHelper getTempFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",fileInfo.fileName]]];
    [request setDownloadProgressDelegate:self];
    //    [request setDownloadProgressDelegate:downCell.progress];//设置进度条的代理,这里由于下载是在AppDelegate里进行的全局下载，所以没有使用自带的进度条委托，这里自己设置了一个委托，用于更新UI
    [request setAllowResumeForFileDownloads:allow];//支持断点续传
    if(isBeginDown)
    {
        fileInfo.isDownloading=YES;
    }
    else
    {
        fileInfo.isDownloading=NO;
    }
    [request setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];//设置上下文的文件基本信息
    [request setTimeOutSeconds:30.0f];
    if (isBeginDown) {
        [request startAsynchronous];
    }
    //filter ads
    if (![AppDelegate NoNotificationFileDownloadRequest:fileInfo]) {
        [_downinglist addObject:request];
    }
    
    [request release];
}
-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown
{
    [self beginRequest:fileInfo isBeginDown:isBeginDown setAllowResumeForFileDownloads:YES];
}
+(BOOL)NoNotificationFileDownloadRequest:(FileModel*)fileModel
{
    return [AppDelegate AdsFileDownloadRequest:fileModel]||[AppDelegate BooksFileDownloadRequest:fileModel];
}
+(BOOL)AdsFileDownloadRequest:(FileModel*)fileModel
{
    return [AdsUrl isEqualToString:fileModel.fileURL ];
}
+(BOOL)BooksFileDownloadRequest:(FileModel*)fileModel
{
    return [kServerBooksUrl isEqualToString:fileModel.fileURL ];
}
-(void)cancelRequest:(ASIHTTPRequest *)request
{
    
}

-(void)loadTempfiles
{
    if (_downinglist) {
        [_downinglist release];
    }
    _downinglist=[[NSMutableArray alloc] init];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    NSArray *filelist=[fileManager contentsOfDirectoryAtPath:[CommonHelper getTempFolderPath] error:&error];
    if(!error)
    {
        NSLog(@"%@",[error description]);
    }
    for(NSString *file in filelist)
    {
        if([file rangeOfString:@".rtf"].location<=100)//以.rtf结尾的文件是下载文件的配置文件，存在文件名称，文件总大小，文件下载URL
        {
            NSInteger index=[file rangeOfString:@"."].location;
            NSString *trueName=[file substringToIndex:index];
            
            //临时文件的配置文件的内容
            NSString *const msgTmp = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[CommonHelper getTempFolderPath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.rtf",trueName]]] encoding:NSUTF8StringEncoding];
            NSString *msg=msgTmp;
            
            //取得第一个逗号前的文件名
            index=[msg rangeOfString:@","].location;
            NSString *name=[msg substringToIndex:index];
            msg=[msg substringFromIndex:index+1];
            
            //取得第一个逗号和第二个逗间的文件总大小
            index=[msg rangeOfString:@","].location;
            NSString *totalSize=[msg substringToIndex:index];
            msg=[msg substringFromIndex:index+1];
            
            //取得第二个逗号后的所有内容，即文件下载的URL
            NSString *url=msg;
            
            //按照获取的文件名获取临时文件的大小，即已下载的大小
            NSData *fileData=[fileManager contentsAtPath:[[CommonHelper getTempFolderPath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",name]]];
            NSInteger receivedDataLength=[fileData length];
            
            //实例化新的文件对象，添加到下载的全局列表，但不开始下载
            FileModel *tempFile=[[FileModel alloc] init];
            tempFile.fileName=name;
            tempFile.fileSize=totalSize;
            tempFile.fileReceivedSize=[NSString stringWithFormat:@"%d",receivedDataLength];
            tempFile.fileURL=url;
            tempFile.isDownloading=NO;
            NSRange range=[tempFile.fileName rangeOfString:@"."];
            if (!tempFile.bookName) {
                tempFile.bookName =(range.length==0)?tempFile.fileName:[tempFile.fileName substringToIndex:range.location];
            }
            
            [self beginRequest:tempFile isBeginDown:NO];
            [msgTmp release];
            [tempFile release];
        }
    }
}
-(NSMutableArray *)finishedlist
{
    [self loadFinishedfiles];
    return _finishedlist;
}

-(void)loadFinishedfiles
{
    if (_finishedlist) {
        [_finishedlist release];
    }
    _finishedlist=[[NSMutableArray alloc] init];
    LatestBooks* bookData =[LatestBooks shareInstance];
    if([bookData.books count]>0)
	{
        NSMutableArray* books = [[NSMutableArray alloc]init];
        for (NSInteger i = 0; i < [bookData.books count]; ++i) {
            RJSingleBook* item = [bookData.books objectAtIndex:i];
            FileModel *finishedFile=[FileModel fileModelFromRJSingleBook:item];
            
            [_finishedlist addObject:finishedFile];
        }
        
        [books release];
	}
}
-(void)initOperationQueue
{
    if(!mOperationQueue)
    {
        mOperationQueue = [[NSOperationQueue alloc]init];
        [mOperationQueue setMaxConcurrentOperationCount:kMaxConcurrentOperationCount];//serial operation
    }
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions begin");
    [self initOperationQueue];
    //向微信注册
    [WXApi registerApp:kWixinChatID];
    [self configureAdsPlatform];
    [self checkUpdate];
    //flurry
    [Flurry startSession:kFlurryID];
    //iTellAFriend
    [iTellAFriend sharedInstance].appStoreID = [kAppIdOnAppstore intValue];
    self.isFistLoadSound=YES;
    
    [[RJBookData sharedRJBookData] importXml:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kLocalBooks]];
    [[LatestBooks shareInstance] loadXml:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kLocalBooks]];
    
    self.isFistLoadSound=NO;
    [self loadTempfiles];
    [self showSideBar];
    [self loadLocalBookData];
    
    return YES;
}
-(void)loadLocalBookData
{
    [self loadAllBookData:[[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:kServerBookFile]];
}

-(void)loadAllBookData:(NSString*)path
{
    NSInvocationOperation* operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(initBookData:) object:path ];
    [mOperationQueue addOperation:operation];
    [operation release];
}
-(void)loadRecommendBookData:(NSString*)path
{
    NSInvocationOperation* operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(initRecommendBookData:) object:path ];
    [mOperationQueue addOperation:operation];
    [operation release];
    
    //load into all book data
    [self loadAllBookData:path];
}

-(void)getServerBooks
{
    FileModel* fileModel = [[FileModel alloc]init];
    fileModel.fileURL = kServerBooksUrl;
    fileModel.fileName = kLocalBooksName;
    
    [self beginRequest:fileModel isBeginDown:YES setAllowResumeForFileDownloads:NO];
    [fileModel release];
}

/*
 - (void)applicationDidFinishLaunching:(UIApplication*)application
 {
 window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
 if (!window)
 {
 return;
 }
 window.backgroundColor = [UIColor blackColor];
 
 navigationController = [[UINavigationController alloc] initWithRootViewController:
 [[RootViewController alloc] init]];
 navigationController.navigationBar.tintColor = COLOR(2, 100, 162);
 
 [window addSubview:navigationController.view];
 [window makeKeyAndVisible];
 [window layoutSubviews];
 }*/

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self getServerBooks];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [mBookData release];
    [mOperationQueue cancelAllOperations];
    [mOperationQueue release];
    [mTrackViewUrl release];
    [_downloadCompleteSound release];
    [_buttonSound release];
    [_finishedlist release];
    [_downloadDelegate release];
    [_downinglist release];
    [window release];
    [navigationController release];
    [super dealloc];
}

#pragma mark ASIHttpRequestDelegate

//出错了，如果是等待超时，则继续下载
-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error=[request error];
    NSLog(@"ASIHttpRequest出错了!%@",error);
}

-(void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"开始了!");
}
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    if(fileInfo)
    {
        fileInfo.fileType=[[request responseHeaders] objectForKey:@"Content-Type"];
        fileInfo.fileSize=[CommonHelper getFileSizeString:[[request responseHeaders] objectForKey:@"Content-Length"]];
        NSLog(@"收到回复了！contentType:%@--fileSize:%@",fileInfo.fileType,fileInfo.fileSize);
        
        //文件开始下载时，把文件名、文件总大小、文件URL写入文件，上海滩.rtf中间用逗号隔开
        NSString *writeMsg=[fileInfo.fileName stringByAppendingFormat:@",%@,%@",fileInfo.fileSize,fileInfo.fileURL];
        NSRange range = [fileInfo.fileName rangeOfString:@"."];
        NSString *name=(range.length==0)?fileInfo.fileName:[fileInfo.fileName substringToIndex:range.location];
        [writeMsg writeToFile:[[CommonHelper getTempFolderPath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.rtf",name]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        [request setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];//设置上下文的文件基本信息
        
    }
}


//1.实现ASIProgressDelegate委托，在此实现UI的进度条更新,这个方法必须要在设置[request setDownloadProgressDelegate:self];之后才会运行
//2.这里注意第一次返回的bytes是已经下载的长度，以后便是每次请求数据的大小
//费了好大劲才发现的，各位新手请注意此处
-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    if(fileInfo && !fileInfo.isFistReceived)
    {
        fileInfo.fileReceivedSize=[NSString stringWithFormat:@"%lld",[fileInfo.fileReceivedSize longLongValue]+bytes];
    }
    if([self.downloadDelegate respondsToSelector:@selector(updateCellProgress:)])
    {
        [self.downloadDelegate updateCellProgress:request];
    }
    fileInfo.isFistReceived=NO;
}

//将正在下载的文件请求ASIHttpRequest从队列里移除，并将其配置文件删除掉,然后向已下载列表里添加该文件对象
-(void)requestFinished:(ASIHTTPRequest *)request
{
#define kHTTPOK 200
    //[self playDownloadFinishSound];
    FileModel *fileInfo=(FileModel *)[request.userInfo objectForKey:@"File"];
    NSLog(@"fileInfo refCount:%d",[fileInfo retainCount]);
    fileInfo.fileType = [[request responseHeaders] objectForKey:@"Content-Type"];
    
    NSRange range=[fileInfo.fileName rangeOfString:@"."];
    NSString *name=(range.length==0)?fileInfo.fileName:[fileInfo.fileName substringToIndex:range.location];
    if (!fileInfo.bookName) {
        fileInfo.bookName = name;
    }
    NSString *configPath=[[CommonHelper getTempFolderPath] stringByAppendingPathComponent:[name stringByAppendingString:@".rtf"]];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    
    if([fileManager fileExistsAtPath:configPath])//如果存在临时文件的配置文件
    {
        [fileManager removeItemAtPath:configPath error:&error];
    }
    if(!error)
    {
        NSLog(@"%@",[error description]);
    }
    if(kHTTPOK != request.responseStatusCode)
    {
        //pop up a tip only
        [[NSNotificationCenter defaultCenter]postNotificationName:kFileDownloadFail object:fileInfo];
    }
    else
    {
        //add to operation queue
        NSInvocationOperation* operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(saveDownloadedResources:) object:fileInfo];
        [mOperationQueue addOperation:operation];
        [operation release];
        
        if(![AppDelegate NoNotificationFileDownloadRequest:fileInfo])
        {
            [_finishedlist addObject:fileInfo];
            [_downinglist removeObject:request];
            NSLog(@"fileInfo refCount:%d",[fileInfo retainCount]);
            //            [_downinglist removeObject:request];
            NSLog(@"fileInfo refCount:%d",[fileInfo retainCount]);
            if([self.downloadDelegate respondsToSelector:@selector(finishedDownload:)])
            {
                [self.downloadDelegate finishedDownload:nil];
            }
            
        }        
    }
}
-(void)initRecommendBookData:(NSObject*)obj
{
    //    @synchronized(self){
    if ([obj isKindOfClass:[NSString class]]) {
        [[RecommendList shareInstance]removeAllBooks];
        [[RecommendList shareInstance] loadXml:(NSString*)obj];
        [[NSNotificationCenter defaultCenter]postNotificationName:kRecommendDatasetChanged object:nil];
    }
    //    }
}
-(void)initBookData:(NSObject*)obj
{
    @synchronized(self.mBookData)
    {
        if ([obj isKindOfClass:[NSString class]]) {
            self.mBookData = [RJBookData sharedRJBookData];
            [self.mBookData loadXml:(NSString*)obj];
            [[NSNotificationCenter defaultCenter]postNotificationName:kDatasetChanged object:nil];
        }
    }
}
-(void)saveDownloadedResources:(FileModel*)fileModel
{
    NSLog(@"saveDownloadedResources:%@",fileModel.fileName);
    
    NSString *documentsDirectory = [CommonHelper getTargetFolderPath];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:fileModel.fileName];
    NSFileManager* fileManager =[NSFileManager defaultManager];
    NSRange range=[fileModel.fileName rangeOfString:@"."];
    NSString *name=(range.length==0)?fileModel.fileName:[fileModel.fileName substringToIndex:range.location];
    if (!fileModel.bookName) {
        fileModel.bookName = name;
    }
    //ads file??
    if ([AppDelegate AdsFileDownloadRequest:fileModel]) {
        [AdsConfig reset];
        AdsConfig *config = [AdsConfig sharedAdsConfig];
        [config init:fileName];
        //show close ads
        if([config wallShouldShow])
        {
            mAdsWalls = [config getAdsWalls];
            //notify observers
            if(![AppDelegate isPurchased])
                [[NSNotificationCenter defaultCenter]postNotificationName:kAdsUpdateDidFinishLoading object:nil];
        }
        return;
    }
    if ([AppDelegate BooksFileDownloadRequest:fileModel]) {
        [self loadRecommendBookData:fileName];
        return;
    }
    //unzip(zip,rar,txt)
    [CommonHelper extractFile:fileName toFile:[CommonHelper getTargetBookPath:fileModel.bookName] fileType:fileModel.fileType];
    
    [fileManager removeItemAtPath:fileName error:nil];
    
    RJSingleBook* book = [RJSingleBook singleBookWithFileModel:fileModel];
    NSLog(@"LatestBooks editBook:%@",book.name);
    [[LatestBooks shareInstance]editBook:book];
    [[NSNotificationCenter defaultCenter]postNotificationName:kFileDownloadSuccess object:fileModel];
}
#pragma mark adswall
-(NSString*)currentAdsWall
{
    if(mAdsWalls)
    {
        //reset index
        if(mAdsWallIndex >= [mAdsWalls count])
        {
            mAdsWallIndex = 0;
        }
        
        //return and prepare for next
        return [mAdsWalls objectAtIndex:mAdsWallIndex++];
    }
    //default wall
    return AdsPlatformDefaultWall;
}
#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[CommonHelper getTargetFolderPath] stringByAppendingPathComponent: @"Bookstore1.0.0.sqlite"]];
	
	NSError *error;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Handle the error.
        NSLog(@"addPersistentStoreWithType error:%@",error);
    }
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

#pragma mark Sidebar
- (BOOL)showSideBar {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
	
	UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
	self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
	self.revealController.view.backgroundColor = bgColor;
	
	RevealBlock revealBlock = ^(){
		[self.revealController toggleSidebar:!self.revealController.sidebarShowing
									duration:kGHRevealSidebarDefaultAnimationDuration];
	};
	
	NSArray *headers = @[
    @"LOCAL",
    @"ONLINE",
    @" "
	];
	NSArray *controllers = @[
    @[
    [[UINavigationController alloc] initWithRootViewController:[[RootViewController alloc] initWithTitle:NSLocalizedString(@"HomePage", @"HomePage") withRevealBlock:revealBlock]]
    ],
    @[
    [[UINavigationController alloc] initWithRootViewController:[[BookStoreViewController alloc] initWithTitle:NSLocalizedString(@"Bookstore", @"Bookstore") withRevealBlock:revealBlock]],
    [[UINavigationController alloc] initWithRootViewController:[[EmbarassViewController alloc] initWithTitle:NSLocalizedString(@"Fun", @"Fun") withRevealBlock:revealBlock]]
    ],
    @[
    [[UINavigationController alloc] initWithRootViewController:[[SoftRcmListViewController alloc]initWithTitle:NSLocalizedString(@"RecommendList", @"Recommend")  withRevealBlock:revealBlock]],
    [[UINavigationController alloc] initWithRootViewController:[[MoreViewController alloc] initWithTitle:NSLocalizedString(@"Setting", @"Setting") withRevealBlock:revealBlock]]
    ]
	];
	NSArray *cellInfos = @[
    @[
    @{kSidebarCellImageKey: [UIImage imageNamed:@"bookreading.png"], kSidebarCellTextKey: NSLocalizedString(@"HomePage", @"HomePage")}
    ],
    @[
    @{kSidebarCellImageKey: [UIImage imageNamed:@"bookstore.png"], kSidebarCellTextKey: NSLocalizedString(@"Bookstore", @"Bookstore")},
    @{kSidebarCellImageKey: [UIImage imageNamed:@"fun.png"], kSidebarCellTextKey: NSLocalizedString(@"Fun", @"Fun")},
    ],
    @[
    @{kSidebarCellImageKey: [UIImage imageNamed:@"recommend.png"], kSidebarCellTextKey: NSLocalizedString(@"RecommendList", @"Recommend")},
    @{kSidebarCellImageKey: [UIImage imageNamed:@"setting.png"], kSidebarCellTextKey: NSLocalizedString(@"Setting", @"Setting")}
    ]
	];
	
	// Add drag feature to each root navigation controller
	[controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		[((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2){
			UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
																						 action:@selector(dragContentView:)];
			panGesture.cancelsTouchesInView = YES;
			[((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
		}];
	}];
	
    /*
     self.searchController = [[GHSidebarSearchViewController alloc] initWithSidebarViewController:self.revealController];
     self.searchController.view.backgroundColor = [UIColor clearColor];
     self.searchController.searchDelegate = self;
     self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
     self.searchController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
     self.searchController.searchBar.backgroundImage = [UIImage imageNamed:@"searchBarBG.png"];
     self.searchController.searchBar.placeholder = NSLocalizedString(@"Search", @"");
     self.searchController.searchBar.tintColor = [UIColor colorWithRed:(58.0f/255.0f) green:(67.0f/255.0f) blue:(104.0f/255.0f) alpha:1.0f];
     for (UIView *subview in self.searchController.searchBar.subviews) {
     if ([subview isKindOfClass:[UITextField class]]) {
     UITextField *searchTextField = (UITextField *) subview;
     searchTextField.textColor = [UIColor colorWithRed:(154.0f/255.0f) green:(162.0f/255.0f) blue:(176.0f/255.0f) alpha:1.0f];
     }
     }
     [self.searchController.searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"searchTextBG.png"]
     resizableImageWithCapInsets:UIEdgeInsetsMake(16.0f, 17.0f, 16.0f, 17.0f)]
     forState:UIControlStateNormal];
     [self.searchController.searchBar setImage:[UIImage imageNamed:@"searchBarIcon.png"]
     forSearchBarIcon:UISearchBarIconSearch
     state:UIControlStateNormal];
     
     self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController
     withSearchBar:self.searchController.searchBar
     withHeaders:headers
     withControllers:controllers
     withCellInfos:cellInfos];
     
     */
    
    GHMenuTitle* titleView = [[[GHMenuTitle alloc] initWithTitle:@"" iconImage:nil] autorelease];
    self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController withTitleView:titleView withHeaders:headers withControllers:controllers withCellInfos:cellInfos];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.revealController;
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark GHSidebarSearchViewControllerDelegate
- (void)searchResultsForText:(NSString *)text withScope:(NSString *)scope callback:(SearchResultsBlock)callback {
	callback(@[@"Foo", @"Bar", @"Baz"]);
}

- (void)searchResult:(id)result selectedAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Selected Search Result - result: %@ indexPath: %@", result, indexPath);
}

- (UITableViewCell *)searchResultCellForEntry:(id)entry atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
	static NSString* identifier = @"GHSearchMenuCell";
	GHMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		cell = [[GHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	cell.textLabel.text = (NSString *)entry;
	cell.imageView.image = [UIImage imageNamed:@"user"];
	return cell;
}

#pragma mark openURL

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [WXApi handleOpenURL:url delegate:self];
}

#pragma mark WXApiDelegate
/*! @brief 收到一个来自微信的请求，处理完后调用sendResp
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        //[self onRequestAppMessage];
        NSString *strTitle = [NSString stringWithFormat:@"消息来自微信"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strTitle delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        [self onShowMediaMessage:temp.message];
    }
    
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"发送提示"];
        NSString *strMsg = [NSString stringWithFormat:@"发送成功"];
        if (resp.errCode!=WXSuccess) {
            strMsg = [resp errStr];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
        //NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
        NSString *strMsg = [NSString stringWithFormat:@"Auth成功"];
        if (resp.errCode!=WXSuccess) {
            strMsg = [resp errStr];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

#pragma mark Weixin SendAppContent
//scene:WXSceneSession;//WXSceneTimeline
- (void) sendAppContent:(NSString*)title description:(NSString*)description image:(NSString*)name scene:(int)scene
{
    if (![WXApi isWXAppInstalled]) {
        [self openWeixinInAppstore];
        return;
    }
    // 发送内容给微信
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    //    if(name && [name length]>0)
    //    {
    //        [message setThumbImage:[UIImage imageNamed:name]];
    //    }
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    //ext.extInfo = @"<xml>test</xml>";
    ext.url = self.mTrackViewUrl;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
    
    [Flurry logEvent:kShareByWeixin];
}

-(void)openWeixinInAppstore
{
    NSString* title = @"提示";
    NSString* msg = @"您需要安装微信后，才能分享，现在去下载？";
    NSString* okMsg =  NSLocalizedString(@"Ok", "");
    NSString* cancelMsg =  NSLocalizedString(@"Cancel", "");
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:okMsg otherButtonTitles:cancelMsg, nil]autorelease];
    [alert show];
    mDialogType = kOpenWeixin;
}

#pragma mark Weixin OnReq
-(void) onShowMediaMessage:(WXMediaMessage *) message
{
    // 微信启动， 有消息内容。
    [self viewContent:message];
}
- (void) viewContent:(WXMediaMessage *) msg
{
    //显示微信传过来的内容
    WXAppExtendObject *obj = msg.mediaObject;
    
    NSString *strTitle = [NSString stringWithFormat:@"消息来自微信"];
    NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, msg.thumbData.length];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

+(BOOL)isPurchased
{
    BOOL r = [[InAppRageIAPHelper sharedHelper].purchasedProducts containsObject:kInAppPurchaseProductName];
    NSLog(@"isPurchased:%d",r);
    return r;
}
#pragma mark alertView delegate
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (mDialogType==kUpdateApp) {
        // the user clicked one of the OK/Cancel buttons
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mTrackViewUrl]];
        }
    }
    else if(mDialogType == kOpenWeixin)
    {
#define kOkIndex 0
        if(buttonIndex == kOkIndex)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
            [Flurry logEvent:kFlurryConfirmOpenWeixinInAppstore];
        }
        else
        {
            [Flurry logEvent:kFlurryCancelOpenWeixinInAppstore];
        }
    }
}
-(void) GetVersionResult:(ASIHTTPRequest *)request
{
    if (!request ) {
        return;
    }
    
    //Response string of our REST call
    NSString* jsonResponseString = [request responseString];
    if (!jsonResponseString || [jsonResponseString length]==0) {
        return;
    }
    
    NSDictionary *loginAuthenticationResponse = [jsonResponseString objectFromJSONString];
    
    NSArray *configData = [loginAuthenticationResponse valueForKey:@"results"];
    NSString* releaseNotes;
    NSString *version = @"";
    for (id config in configData)
    {
        version = [config valueForKey:@"version"];
        self.mTrackViewUrl = [config valueForKey:@"trackViewUrl"];
        releaseNotes = [config valueForKey:@"releaseNotes"];
        //self.mTrackName = [config valueForKey:@"trackName"];
        //NSLog(@"%@",mTrackName);
    }
    NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //Check your version with the version in app store
    if ([AppDelegate CompareVersionFromOldVersion:localVersion newVersion:version])
    {
        UIAlertView *createUserResponseAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NewVersion", @"") message: @"" delegate:self cancelButtonTitle:NSLocalizedString(@"Back", @"") otherButtonTitles: NSLocalizedString(@"Ok", @""), nil];
        [createUserResponseAlert show];
        [createUserResponseAlert release];
        mDialogType = kUpdateApp;
    }
    
    [Flurry logEvent:[NSString stringWithFormat:@"localVersion:%@-newVersion:%@",localVersion,version]];
}

// 比较oldVersion和newVersion，如果oldVersion比newVersion旧，则返回YES，否则NO
// Version format[X.X.X]
+(BOOL)CompareVersionFromOldVersion : (NSString *)oldVersion
                         newVersion : (NSString *)newVersion
{
    NSArray*oldV = [oldVersion componentsSeparatedByString:@"."];
    NSArray*newV = [newVersion componentsSeparatedByString:@"."];
    
    if (oldV.count == newV.count) {
        for (NSInteger i = 0; i < oldV.count; i++) {
            NSInteger old = [(NSString *)[oldV objectAtIndex:i] integerValue];
            NSInteger new = [(NSString *)[newV objectAtIndex:i] integerValue];
            if (old < new) {
                return YES;
            }
        }
        return NO;
    } else {
        return NO;
    }
}

#pragma  mark loading background task
-(void)configureAdsPlatform
{
    [[MobiSageManager getInstance] setPublisherID:kMobiSageID_iPhone];
    //NSLog(@"MobisagePulisherID: %@",[MobiSageManager getInstance]->m_publisherID);
    //disable youmi wall gps
    [YouMiWall setShouldGetLocation:NO];
    [YouMiWall setShouldCacheImage:YES];
    
    
    //注意:这里必须填写您的App_ID. 您可以从www.waps.cn注册后获取,pid为渠道编号,比如@"appstore",@"91"
	//[AppConnect getConnect:@"1bf390a13d540df7bf72418498dfe503" pid:@"appstore"];
    //[AppConnect getConnect:kWapsId]; //不指定pid
    
    FileModel* fileModel = [[FileModel alloc]init];
    fileModel.fileURL = AdsUrl;
    fileModel.fileName = AdsLocalName;
    [self beginRequest:fileModel isBeginDown:YES setAllowResumeForFileDownloads:NO];
    [fileModel release];
}
-(void)checkUpdateTask
{
    //not published on appstore
    if(kAppIdOnAppstore.length==0)
    {
        return;
    }
    
    NSString* updateLookupUrl = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",kAppIdOnAppstore];
    NSURL *url = [NSURL URLWithString:updateLookupUrl];
    ASIFormDataRequest* versionRequest = [ASIFormDataRequest requestWithURL:url];
    [versionRequest setRequestMethod:@"GET"];
    [versionRequest setDelegate:self];
    [versionRequest setTimeOutSeconds:150];
    [versionRequest addRequestHeader:@"Content-Type" value:@"application/json"];
    [versionRequest setDidFinishSelector:@selector(GetVersionResult:)];
    [versionRequest startAsynchronous];
}
-(void)checkUpdate
{
    NSInvocationOperation* operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(checkUpdateTask) object:nil];
    [mOperationQueue addOperation:operation];
    [operation release];
}
@end