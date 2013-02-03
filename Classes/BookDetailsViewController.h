//
//  BookDetailsViewController.h
//  MyLauncher
//
//  Created by lxl on 12-11-11.
//
//

#import <UIKit/UIKit.h>
#import "BSBaseViewController.h"

@class RJSingleBook;

@interface BookDetailsViewController : BSBaseViewController
{
    UIImageView* _bookIconImageView;
    UILabel* _bookName;
    UILabel* _bookAuthor;
    UILabel* _boolTotalChar;
    UIButton* _downLoadBtn;
    UIImageView* _lineImage;
    UITextView* _summuryView;
    
    RJSingleBook* _book;
}

@property(nonatomic,retain)IBOutlet UIImageView* bookIconImageView;
@property(nonatomic,retain)IBOutlet UILabel* bookName;
@property(nonatomic,retain)IBOutlet UILabel* bookAuthor;
@property(nonatomic,retain)IBOutlet UILabel* boolTotalChar;
@property(nonatomic,retain)IBOutlet UIButton* downLoadBtn;
@property(nonatomic,retain)IBOutlet UIImageView* lineImage;
@property(nonatomic,retain)IBOutlet UITextView* summuryView;


@property(nonatomic, retain) RJSingleBook* book;

-(IBAction)downLoadBtnPressed:(id)sender;

@end
