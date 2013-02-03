//
//  MoreViewController.h
//  AccountSafe
//
//  Created by Lee Ramon on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#ifndef __RevealBlock__
#define __RevealBlock__
typedef void (^RevealBlock)();
#endif

@interface MoreViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate>
{
@private
	RevealBlock _revealBlock;
}
@property(nonatomic,retain) IBOutlet UITableView* tableView;

- (IBAction)feedback:(id)sender;

-(void)launchMailAppOnDevice:(BOOL)feedback;
-(void)displayComposerSheet:(BOOL)feedback;

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;
@end
