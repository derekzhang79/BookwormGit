//
//  SoftRcmListViewController.h
//  Sample
//
//  Created by xiaolin liu on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobiSageRecommendSDK.h"

@class SoftRcmList;
@class YouMiWall;
#ifndef __RevealBlock__
#define __RevealBlock__
typedef void (^RevealBlock)();
#endif

@interface SoftRcmListViewController : UITableViewController<MobiSageRecommendDelegate>
{
    SoftRcmList *_softRcmList;
    YouMiWall *wall;
    NSMutableArray *openApps;
    MobiSageRecommendView *_recmdView;
@private
	RevealBlock _revealBlock;
}
@property(nonatomic, retain) MobiSageRecommendView *recmdView;
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;
@end
