//
//  RootViewController.h
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

#import <UIKit/UIKit.h>
#import "MyLauncherViewController.h"
#import "YouMiWall.h"
#import "MobiSageRecommendSDK.h"
#import <immobSDK/immobView.h>

#ifndef __RevealBlock__
#define __RevealBlock__
typedef void (^RevealBlock)();
#endif

@interface RootViewController : MyLauncherViewController<YouMiWallDelegate,UIAlertViewDelegate,MobiSageRecommendDelegate,immobViewDelegate>
{
	RevealBlock _revealBlock;
    BOOL mControllerVisible;
    YouMiWall *wall;
    UIView* mImmobWall;//
	NSMutableArray *openApps;
    MobiSageRecommendView *_recmdView;
}
@property(nonatomic, retain) MobiSageRecommendView *recmdView;
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;
@end