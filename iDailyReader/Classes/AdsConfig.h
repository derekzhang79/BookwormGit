//
//  AdsConfig.h
//  HappyLife
//
//  Created by ramon lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//appstore switch
//#define k91Appstore
//#define __IN_APP_SUPPORT__

//appid
#define kAppIdOnAppstore @"586030218"
//flurry
#define kFlurryID @"K6HT5WRCH3JJ5HF5KRHS"

//ads url
#define kDefaultAds @"defaultAds"

#ifdef k91Appstore
#define AdsUrl @"http://www.idreems.com/example.php?adsconfigNonAppstore.xml"
#else
#define AdsUrl @"http://www.idreems.com/example.php?adsconfig20.xml"
#endif
#define AdsLocalName @"AdsLocalName.xml"




#define kInAppPurchaseProductName @"com.idreems.bookworm"
#define kWixinChatID @"wxdc2aaf94a5470e5d"

//weibo key and secret
//sina weibo
#define kOAuthConsumerKey				@"1833188142"		//REPLACE ME
#define kOAuthConsumerSecret			@"249f839bf79ddf8cf755f96e947e01a9"		//REPLACE ME

//wall
//修改为你自己的AppID和AppSecret
#define kDefaultAppID_iOS           @"5aa5eabf0f6bef1d" // youmi default app id
#define kDefaultAppSecret_iOS       @"5e9ee87631d15545" // youmi default app secret


//id for ads
#define kMobiSageIDOther_iPhone @"aef1fcef8e0b48d9978c1d3b1928a76f"
#define kMobiSageID_iPhone  @"57d88c9bfe0e420387acbea0bbe16264"
#define kWiyunID_iPhone  @"cbd2ecdce0638c28"
#define kWiyunID_iPad    @"7ef7469b8144e036"
#define kWoobooPublisherID  @"3edc2f2cce9c4cc9a530f297a6cc54a1"
#define kDomobPubliserID @"56OJyOqouMF2Jf1Hdq"
#define kCaseeIPhoneId         @"4FB83ED3982EC730A8490A7BCAEDBAF0"
#define kCaseeIPadId @"D2C1D2621157FA73F29875AF3875AF4D"
#define kYoumiId kDefaultAppID_iOS
#define kYoumiSecret kDefaultAppSecret_iOS
#define kAdmobID @"a14f1b56e4ba533"
#define kWapsId @"6742d5de04cf0a6a5bf45fd3cdc9001a"


#define kImmobBannerId @"25d37c3d48c33556e68fcd9ceb1fdd67"
#define kImmobWallId @"69b92a0f35cd484d4d93de787397b7d9"


//ads platform names
#define AdsPlatformWooboo @"Wooboo"
#define AdsPlatformWiyun @"Wiyun"
#define AdsPlatformMobisage @"Mobisage"
#define AdsPlatformMobisageOther @"MobisageOther"
#define AdsPlatformDomob @"Domob"
#define AdsPlatformYoumi @"Youmi"//not implemented right now
#define AdsPlatformCasee @"Casee"
#define AdsPlatformAdmob @"Admob"
#define AdsPlatformMobisageRecommend @"MobisageRecommend"
#define AdsPlatformMobisageRecommendOther @"MobisageRecommendOther"
#define AdsPlatformWQMobile @"WQMobile"
#define AdsPlatformImmob @"Immob"
#define AdsPlatformMiidi @"miidi"
#define AdsPlatformWaps @"waps"

//ads wall
#define AdsPlatformImmobWall @"ImmobWall"
#define AdsPlatformYoumiWall @"YoumiWall"
#define AdsPlatformWapsWall @"WapsWall"
#define AdsPlatformMobisageWall @"MobisageWall"
#define AdsPlatformDefaultWall AdsPlatformYoumiWall



#define kNewContentScale 5
#define kMinNewContentCount 3

#define kWeiboMaxLength 140
#define kAdsSwitch @"AdsSwitch"
#define kPermanent @"Permanent"
#define kDateFormatter @"yyyy-MM-dd"

//for notification
#define kAdsUpdateDidFinishLoading @"AdsUpdateDidFinishLoading"
#define  kUpdateTableView @"UpdateTableView"

#define kOneDay (24*60*60)
#define kTrialDays  1

//flurry event
#define kFlurryRemoveTempConfirm @"kRemoveTempConfirm"
#define kFlurryRemoveTempCancel  @"kRemoveTempCancel"
#define kEnterMainViewList       @"kEnterMainViewList"
#define kFlurryOpenRemoveAdsList @"kOpenRemoveAdsList"

#define kFlurryDidSelectApp2RemoveAds @"kDidSelectApp2RemoveAds"
#define kFlurryRemoveAdsSuccessfully  @"kRemoveAdsSuccessfully"
#define kDidShowFeaturedAppNoCredit   @"kDidShowFeaturedAppNoCredit"

#define kShareByWeibo @"kShareByWeibo"
#define kShareByEmail @"kShareByEmail"

#define kEnterBylocalNotification @"kEnterBylocalNotification"
#define kDidShowFeaturedAppCredit @"kDidShowFeaturedAppCredit"

#define kFlurryDidSelectAppFromRecommend @"kFlurryDidSelectAppFromRecommend"
#define kFlurryDidSelectAppFromMainList  @"kFlurryDidSelectAppFromMainList"
#define kFlurryDidReviewContentFromMainList  @"kFlurryDidReviewContentFromMainList"
#define kLoadRecommendAdsWall @"kLoadRecommendAdsWall"
//favorite
#define kEnterNewFavorite @"kEnterNewFavorite"
#define kOpenExistFavorite @"kOpenExistFavorite"
#define kQiushiReviewed @"kQiushiReviewed"
#define kQiushiRefreshed @"kQiushiRefreshed"

//weixin
#define kFlurryConfirmOpenWeixinInAppstore @"kConfirmOpenWeixinInAppstore"
#define kFlurryCancelOpenWeixinInAppstore @"kCancelOpenWeixinInAppstore"
#define kShareByWeixin @"kShareByWeixin"

#define kCountPerSection 3
@interface AdsConfig : NSObject
{
    NSMutableArray *mData;
    NSInteger mCurrentIndex;
    NSMutableArray* mAdsWalls;
}
@property (nonatomic, retain) NSMutableArray* mData;
@property (nonatomic, assign) NSInteger mCurrentIndex;

+(AdsConfig*)sharedAdsConfig;
+(void)reset;
+(NSDate*)currentLocalDate;

+(BOOL) isAdsOn;
+(BOOL) isAdsOff;
+(void) setAdsOn:(BOOL)enable type:(NSString*)type;
+(BOOL)neverCloseAds;

-(NSString*)wallShowString;
-(NSString *)getAdsTestVersion:(const NSUInteger)index;
-(BOOL)wallShouldShow;
-(void)init:(NSString*)path;
-(NSArray*)getAdsWalls;

-(NSString*)getFirstAd;

-(NSString*)getLastAd;

-(NSInteger)getAdsCount;

-(NSString*)toNextAd;

-(NSString*)getCurrentAd;

-(BOOL)isCurrentAdsValid;
-(NSInteger)getCurrentIndex;

-(BOOL)isInitialized;

-(void)dealloc;

@end
