//
//  RootViewController.m
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

#import "RootViewController.h"
#import "MyLauncherItem.h"
#import "CustomBadge.h"
//#import "ExamplesViewController.h"
#import "BaiduMusicViewController.h"
#import "DownloadViewController.h"
//#import "PDFExampleViewController.h"
#import "LatestBooks.h"
#import "RJBookData.h"
#import "Tree.h"
#import "KDBooKViewController.h"
#import "CommonHelper.h"
#import "BookStoreViewController.h"
#import "AdsConfig.h"
#import "Flurry.h"

#define kLoadMobisageRecommendViewDelayTime 10//s
#define kNextDelayTime 10*60

@interface RootViewController()
{
    BOOL mYoumiFeaturedWallShown;
    BOOL mYoumiFeaturedWallClosed;
    BOOL mYoumiFeaturedWallLoadSuccess;
    BOOL mYoumiFeaturedWallShouldShow;//time's up for the next youmi wall show
    BOOL mYoumiFeatureWallShowCount;
}

-(void)closeAds:(BOOL)popClosingTip;
-(void)loadNeededView;
-(void)loadYoumiWall:(BOOL)credit;
-(void)loadAdsageRecommendView:(BOOL)visible;
-(void)loadRecommendAdsWall:(NSString*)wallName;
@end


@implementation RootViewController
@synthesize recmdView = _recmdView;

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock {
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = title;
		_revealBlock = [revealBlock copy];
		self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                      target:self
                                                      action:@selector(revealSidebar)];
	}
	return self;
}
- (void)revealSidebar {
	_revealBlock();
}
-(void)loadView
{
	[super loadView];
    
    self.title = NSLocalizedString(@"Bookworm", @"Bookworm");
    
    //Add your view controllers here to be picked up by the launcher; remember to import them above
    //[[self appControllers] setObject:[ExamplesViewController class] forKey:@"ExamplesViewController"];
    //[[self appControllers] setObject:[PDFExampleViewController class] forKey:@"PDFExampleViewController"];
    [[self appControllers] setObject:[KDBooKViewController class] forKey:@"KDBooKViewController"];
    
    //API doc
    //title for book's title
    //iPhoneImage/iPadImage for image of this book
    //targetTitle:for book's name,find the book in the library(file name)
    //deletable:this item is deletable or not
	
    
    // Set badge text for a MyLauncherItem using it's setBadgeText: method
    //[(MyLauncherItem *)[[[self.launcherView pages] objectAtIndex:0] objectAtIndex:0] setBadgeText:@"4"];
    
    // Alternatively, you can import CustomBadge.h as above and setCustomBadge: as below.
    // This will allow you to change colors, set scale, and remove the shine and/or frame.
    //[(MyLauncherItem *)[[[self.launcherView pages] objectAtIndex:0] objectAtIndex:1] setCustomBadge:[CustomBadge customBadgeWithString:@"2" withStringColor:[UIColor blackColor] withInsetColor:[UIColor whiteColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor blackColor] withScale:0.8 withShining:NO]];
    
    //[(MyLauncherItem *)[[[self.launcherView pages] objectAtIndex:0] objectAtIndex:0] setCustomBadge:[CustomBadge customBadgeWithString:@"6" withStringColor:[UIColor whiteColor] withInsetColor:[UIColor redColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor whiteColor] withScale:1 withShining:NO]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(FileDownloadSuccess:) name:kFileDownloadSuccess object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(FileDownloadFail:) name:kFileDownloadFail object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DidDeleteItem:) name:kDidDeleteItem object:nil];
    
}
-(void)refresh
{
    if(!mControllerVisible)
    {
        return;
    }
    LatestBooks* bookData = [LatestBooks shareInstance];
    //TODO::order according to it's position
    
    //API doc
    //title for book's title
    //iPhoneImage/iPadImage for image of this book
    //targetTitle:for book's name,find the book in the library(file name)
    //deletable:this item is deletable or not
	if([bookData.books count]>0)
	{
        NSMutableArray* books = [[NSMutableArray alloc]init];
        for (NSInteger i = 0; i < [bookData.books count]; ++i) {
            RJSingleBook* item = [bookData.books objectAtIndex:i];
            if ([CommonHelper isExistFile:item.bookFullPathName]) {
                [books addObject:[[MyLauncherItem alloc] initWithTitle:item.name
                                                           iPhoneImage:item.icon
                                                             iPadImage:item.icon
                                                                target:@"KDBooKViewController"
                                                           targetTitle:item.bookFullPathName
                                                             deletable:YES]];
            }
        }
        [self.launcherView clearPages];
        [self.launcherView setPages:books singleArray:YES];
        [books release];
        
        // Set number of immovable items below; only set it when you are setting the pages as the
        // user may still be able to delete these items and setting this then will cause movable
        // items to become immovable.
        // [self.launcherView setNumberOfImmovableItems:1];
        
        // Or uncomment the line below to disable editing (moving/deleting) completely!
        // [self.launcherView setEditingAllowed:NO];
	}
    
}

-(void)makeToast:(FileModel*)fileModel
{
    if([self.view respondsToSelector:@selector(makeToast:)])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@ 下载完毕！",fileModel.bookName ]];
        //[APPDELEGATE playDownloadFinishSound];
    }
}
#pragma mark notification handler

-(void)DidDeleteItem:(NSNotification *)notification
{
    if(notification && [notification.object isKindOfClass:[MyLauncherItem class]])
    {
        MyLauncherItem* item = (MyLauncherItem*)notification.object;
        LatestBooks* books = [LatestBooks shareInstance];
        NSUInteger i =  [books indexOfObject:item.title];
        if(kNotFound != i)
        {
            RJSingleBook* book = [books.books objectAtIndex:i];
            FileModel* fileModel = [FileModel fileModelFromRJSingleBook:book];
            [CommonHelper deleteFinishedBook:fileModel];
        }
    }
}

-(void)FileDownloadFail:(NSNotification *)notification
{
    if (notification) {
        FileModel* fileModel =  (FileModel*)notification.object;
        if (fileModel && [self.view respondsToSelector:@selector(makeToast:)]) {
            [self.view makeToast:[NSString stringWithFormat:@"下载 %@ 失败，请重试！",fileModel.bookName ]];
        }
    }
}
-(void)FileDownloadSuccess:(NSNotification *)notification
{
    if (notification) {
        FileModel* fileModel =  (FileModel*)notification.object;
        NSLog(@"fileInfo refCount:%d",[fileModel retainCount]);
        if (fileModel) {
            //update UI
            [self performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(makeToast:) withObject:fileModel waitUntilDone:YES];
        }
    }
}
-(void)launcherViewItemSelected:(MyLauncherItem*)item {
    if (![self appControllers] || [self launcherNavigationController]) {
        return;
    }
    if (!item.title || [item.title length]==0) {
        return;
    }
    Class viewCtrClass = [[self appControllers] objectForKey:[item controllerStr]];
	UIViewController *controller = [[viewCtrClass alloc] init];
	
    //TODO::get item index
    if([controller isKindOfClass:[KDBooKViewController class]])
    {
        KDBooKViewController* ctrl = (KDBooKViewController*)controller;
        ctrl.bookIndex = [[LatestBooks shareInstance] indexOfObject:item.title];
    }
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	//If you don't want to support multiple orientations uncomment the line below
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
	//return [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad
{
    [self loadAdsageRecommendView:NO];
    if(openApps==nil)
    {
        openApps = [[NSMutableArray alloc] init];
    }
    mYoumiFeatureWallShowCount = 0;
    mYoumiFeaturedWallShown = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeAds:) name:kAdsUpdateDidFinishLoading object:nil];
}
- (IBAction)segmentAction:(id)sender
{
#define kOnlineStore 1
	// The segmented control was clicked, handle it here
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	NSLog(@"Segment clicked: %d", segmentedControl.selectedSegmentIndex);
    if(segmentedControl.selectedSegmentIndex == kOnlineStore)
    {
        [self openOnlineStore];
    }
    else
    {
        [self openMainView];
    }
}
-(IBAction)openOnlineStore
{
    UIViewController* controller = [[BaiduMusicViewController alloc]initWithNibName:@"BaiduMusicViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}
-(IBAction)openDownload
{
    UIViewController* controller = [[DownloadViewController alloc]initWithNibName:@"DownloadViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
}
- (void)openMainView
{
    BookStoreViewController* vc  =[[[BookStoreViewController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    mControllerVisible = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    mControllerVisible = YES;
    [self refresh];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    wall.delegate = nil;
    [wall release];
    [openApps release];
    self.recmdView = nil;
    [super dealloc];
    
}

-(void)loadYoumiWall:(BOOL)credit
{
    //    AdsConfig* config = [AdsConfig sharedAdsConfig];
    //    if(![config wallShouldShow])
    //    {
    //       return;
    //    }
    
    //load youmi wall
    if(!wall)
    {
        wall = [[YouMiWall alloc] init];
        wall.delegate = self;
        wall.appID = kDefaultAppID_iOS;
        wall.appSecret = kDefaultAppSecret_iOS;
    }
    if(credit)
    {
        // 添加应用列表开放源观察者
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestOffersOpenDataSuccess:) name:YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION object:nil];
        
        [wall requestOffersAppData:credit pageCount:15];
    }
    else
    {
        // 添加应用列表开放源观察者
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFeaturedOffersSuccess) name:YOUMI_FEATURED_APP_RESPONSE_NOTIFICATION object:nil];
        
        [wall requestFeaturedApp:credit];
    }
}
-(void)loadAdsageRecommendView:(BOOL)visible
{
    [[MobiSageManager getInstance]setPublisherID:kMobiSageID_iPhone];
    if (self.recmdView == nil)
    {
        const NSUInteger size = 24;//mobisage recommend default view size
        _recmdView = [[MobiSageRecommendView alloc]initWithDelegate:self andImg:nil];
                
        self.recmdView.frame = CGRectMake(0, size/2, size, size);
    }
//    if (visible) {
//        [self.navigationController.view addSubview:self.recmdView];
//    }
    if(visible)
    {
        //add to navigation
        UIBarButtonItem *naviLeftItem = [[UIBarButtonItem alloc] initWithCustomView:self.recmdView];
        self.navigationItem.rightBarButtonItem = naviLeftItem;
        [naviLeftItem release];
    }
}
-(void)loadFeaturedYoumiWall
{
    if(!mYoumiFeaturedWallShown)
    {
        [self loadYoumiWall:NO];
    }
}
-(void)shouldShowYoumiWall
{
    mYoumiFeaturedWallShouldShow = YES;
}

#pragma mark - YouMiWall delegate
-(void)requestFeaturedOffersSuccess
{
    mYoumiFeaturedWallLoadSuccess = YES;
    mYoumiFeaturedWallShown = YES;
    mYoumiFeaturedWallClosed = NO;
    if(!self.view.isHidden)
    {
        [wall showFeaturedApp:YouMiWallAnimationTransitionPushFromBottom];
        [Flurry logEvent:kDidShowFeaturedAppNoCredit];
    }
}
// 隐藏全屏页面
//
// 详解:
//      全屏页面隐藏完成后回调该方法
// 补充:
//      查看YOUMI_WALL_VIEW_CLOSED_NOTIFICATION
//
- (void)didDismissWallView:(YouMiWall *)adWall
{
    mYoumiFeaturedWallClosed = YES;
    mYoumiFeaturedWallShown = NO;
}
// 显示全屏页面
//
// 详解:
//      全屏页面显示完成后回调该方法
// 补充:
//      查看YOUMI_WALL_VIEW_OPENED_NOTIFICATION
//
- (void)didShowWallView:(YouMiWall *)adWall
{
    mYoumiFeatureWallShowCount++;
    mYoumiFeaturedWallShown = YES;
    mYoumiFeaturedWallClosed = NO;
}
- (void)requestOffersOpenDataSuccess:(NSNotification *)note {
    NSLog(@"--*-1--[Rewarded]requestOffersOpenDataSuccess:-*--");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YOUMI_OFFERS_APP_DATA_RESPONSE_NOTIFICATION object:nil];
    
    
    {
        AppDelegate* delegate= (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSDictionary *info = [note userInfo];
        NSArray *apps = [info valueForKey:YOUMI_WALL_NOTIFICATION_USER_INFO_OFFERS_APP_KEY];
        NSString* docDir= [delegate applicationDocumentsDirectory];
        
        
        for (NSUInteger i = 0; i<[apps count]; ++i) {
            YouMiWallAppModel *model = [apps objectAtIndex:i];
            NSLog(@"model:%@",model) ;
            
            NSString* smallIconUrl = model.smallIconURL;
            
            NSString* smallIconFileName = [NSString stringWithFormat:@"%@%@",model.name,model.storeID];
            NSString* localIconFileName = [NSString stringWithFormat:@"%@%@%@",docDir,@"/",smallIconFileName];
            NSData* localData = [NSData dataWithContentsOfFile:localIconFileName];
            if (localData==nil || localData.length==0) {
                localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", smallIconUrl]]];
                [localData writeToFile:localIconFileName atomically:YES];
            }
        }
        
        //add to listview
        if(apps && [apps count]>0)
        {
            if(openApps==nil)
            {
                openApps = [[NSMutableArray alloc] init];
            }
            [openApps addObjectsFromArray:apps];
            
            //            [self.tableView reloadData];
        }
    }
}

#pragma mark API
- (IBAction)modalViewAction:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"AboutTitle", @"") message:NSLocalizedString(@"About", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Done",@"") otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)popupAdsageRecommendView:(NSString*)wallName
{
    if(NSOrderedSame==[AdsPlatformMobisageWall caseInsensitiveCompare:wallName])
    {
        [self loadAdsageRecommendView:YES];
        [self.recmdView OpenAdSageRecmdModalView];
    }
    else if(NSOrderedSame==[AdsPlatformWapsWall caseInsensitiveCompare:wallName])
    {
        //[AppConnect showOffers];
    }
    else if(NSOrderedSame==[AdsPlatformImmobWall caseInsensitiveCompare:wallName])
    {
        if(mImmobWall)
        {
            [mImmobWall release];
        }
        mImmobWall=[[immobView alloc] initWithAdUnitID:kImmobWallId];
        //此属性针对多账户用户，主要用于区分不同账户下的积分
        //        [mWall.UserAttribute setObject:@"immobSDK" forKey:@"accountname"];
        ((immobView*)mImmobWall).delegate=self;
        [mImmobWall release];
        [((immobView*)mImmobWall) immobViewRequest];
    }
    else //if(NSOrderedSame==[AdsPlatformYoumiWall caseInsensitiveCompare:wallName])
    {
        [self loadFeaturedYoumiWall];
    }
    
    [self performSelector:@selector(popupAdsageRecommendView:) withObject:[SharedDelegate currentAdsWall] afterDelay:kNextDelayTime];
}
-(void)loadRecommendAdsWall:(NSString*)wallName
{
    [self loadAdsageRecommendView:YES];
    [self performSelector:@selector(popupAdsageRecommendView:) withObject:wallName afterDelay:kLoadMobisageRecommendViewDelayTime];
}
#pragma mark immob delegate
/**
 *email phone sms等所需要
 *返回当前添加immobView的ViewController
 */
- (UIViewController *)immobViewController{
    
    return self;
}

/**
 *根据广告的状态来决定当前广告是否展示到当前界面上 AdReady
 *YES  当前广告可用
 *NO   当前广告不可用
 */
- (void) immobViewDidReceiveAd:(BOOL)AdReady{
    if (AdReady) {
        immobView* imView = (immobView*)(mImmobWall);
        [self.view addSubview:imView];
        [imView immobViewDisplay];
    }
    else {
        [self loadFeaturedYoumiWall];
    }
}

#pragma closeAds temporarily
-(void)closeAds:(BOOL)popClosingTip
{
    //[self loadYoumiWall:YES];
    AppDelegate* delegate = SharedDelegate;
    [self performSelectorOnMainThread:@selector(loadRecommendAdsWall:) withObject:[delegate currentAdsWall] waitUntilDone:YES];
//    [self loadRecommendAdsWall:[delegate currentAdsWall]];
    [self loadAdsageRecommendView:YES];
}

#pragma mark AdSageRecommendDelegate
- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

@end
