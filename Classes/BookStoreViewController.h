//
//  MainViewController.h
//  MyLauncher
//
//  Created by lxl on 12-11-11.
//
//

#import <UIKit/UIKit.h>

enum TabItemTag {
    RecmdItemTag = 1,
    ClassCataloguesTag,
    DownloadTag
    };
#ifndef __RevealBlock__
#define __RevealBlock__
typedef void (^RevealBlock)();
#endif
@interface BookStoreViewController : UITabBarController
{
@private
	RevealBlock _revealBlock;
}
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;
@end
